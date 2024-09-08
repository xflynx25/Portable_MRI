import torch
import torch.nn as nn
import torch.optim as optim
import matplotlib.pyplot as plt
from helpers.plotting import plot_square_subplots
import numpy as np 

class CNNModel(nn.Module):
    def __init__(self):
        super(CNNModel, self).__init__()
        self.layer1 = nn.Sequential(
            nn.Conv2d(2, 128, kernel_size=11, stride=1, padding=5),
            nn.BatchNorm2d(128),
            nn.ReLU()
        )
        self.layer2 = nn.Sequential(
            nn.Conv2d(128, 64, kernel_size=9, stride=1, padding=4),
            nn.BatchNorm2d(64),
            nn.ReLU()
        )
        self.layer3 = nn.Sequential(
            nn.Conv2d(64, 32, kernel_size=5, stride=1, padding=2),
            nn.BatchNorm2d(32),
            nn.ReLU()
        )
        self.layer4 = nn.Sequential(
            nn.Conv2d(32, 32, kernel_size=1, stride=1),
            nn.BatchNorm2d(32),
            nn.ReLU()
        )
        self.layer5 = nn.Conv2d(32, 2, kernel_size=7, stride=1, padding=3)
        
    def forward(self, x):
        out = self.layer1(x)
        out = self.layer2(out)
        out = self.layer3(out)
        out = self.layer4(out)
        out = self.layer5(out)
        return out
    
def train_model(input_data, target_data, epochs=20):
    # Initialize model, loss function, and optimizer
    model = CNNModel()
    criterion = nn.MSELoss()
    optimizer = optim.Adam(model.parameters(), lr=0.0005, betas=(0.9, 0.999))

    # Training loop
    for epoc in range(epochs):
        optimizer.zero_grad()
        outputs = model(input_data)
        loss = criterion(outputs, target_data)
        loss.backward()
        optimizer.step()
        print(f"Epoch [{epoc+1}/20], Loss: {loss.item():.4f}")

    return model

def train_calibration_model(calibration_data, test_data, epochs=20):
    NFE, PE, Ns, _ = calibration_data.shape  # Assuming calibration_data is of shape (FE, PE, Nc, 2)

    # Split the data into row chunks for calibration and test data
    Xtrain_chunks = [calibration_data[:, i, 1:, :].reshape(NFE, Ns-1, 2) for i in range(PE)]
    ytrain_chunks = [calibration_data[:, i, 0, :].reshape(NFE, 2) for i in range(PE)]

    Xtest_chunks = [test_data[:, i, 1:, :].reshape(NFE, Ns-1, 2) for i in range(PE)]
    ytest_chunks = [test_data[:, i, 0, :].reshape(NFE, 2) for i in range(PE)]

    # Convert lists of rows into numpy arrays
    Xtrain_chunks = np.stack(Xtrain_chunks, axis=0)
    ytrain_chunks = np.stack(ytrain_chunks, axis=0)

    Xtest_chunks = np.stack(Xtest_chunks, axis=0)
    ytest_chunks = np.stack(ytest_chunks, axis=0)

    print(Xtrain_chunks.shape)

    # Initialize placeholders for the assembled predictions
    y_predict_full = np.zeros_like(ytest_chunks)

    # Train the model on each row chunk
    for i in range(len(Xtrain_chunks)):
        print(f"Training on row {i+1}/{len(Xtrain_chunks)}...")
        calib_tensor = torch.tensor(Xtrain_chunks[i], dtype=torch.float32)
        test_tensor = torch.tensor(ytrain_chunks[i], dtype=torch.float32)

        # Train model on this single row
        model = train_model(calib_tensor, test_tensor, epochs=epochs)

        # Predict the row using the trained model
        with torch.no_grad():
            test_tensor = torch.tensor(Xtest_chunks[i], dtype=torch.float32)
            y_predict_row = model(test_tensor).cpu().numpy().reshape(NFE)
            y_predict_full[i, :] = y_predict_row

    # Assemble and plot the results
    actual_image = ytest_chunks.reshape(PE, NFE)
    predicted_image = y_predict_full.reshape(PE, NFE)
    
    plot_square_subplots([actual_image, predicted_image],
                         titles=["Actual Image", "Predicted Image"],
                         suptitle="Comparison of Actual vs Predicted",
                         color_map='gray')
    plt.show()

    return model, y_predict_full

# Example usage:
if __name__ == '__main__':
    calibration_data = np.random.randn(128, 40, 4, 2)  # Example calibration data (FE x PE x Nc)
    test_data = np.random.randn(128, 40, 4, 2)  # Corresponding test data

    model, predictions = train_calibration_model(calibration_data, test_data, epochs=20)