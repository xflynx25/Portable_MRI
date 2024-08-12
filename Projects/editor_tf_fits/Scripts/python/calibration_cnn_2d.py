import os
import numpy as np
import matplotlib.pyplot as plt
from helpers.plotting import plot_square_subplots
from nn_calibration import train_calibration_model
import torch
import torch.nn as nn
import torch.optim as optim

# INPUTS 
##################

exp_name = 'tnt_preprocessed_data_2Dsequence_2Dtable_calibration_singleecho_trigearly_4rx_1repeat_260_gain60_ball_5th_trial2'

# Inputs
Nc = 4
SLICE_TO_PLOT = 1
PLOT_RECON = True
EDITER_CALIBRATION_COMPARISON = False
DL_CALIBRATION_COMPARISON = True


##################
##################
##################
##################


# LOADING 
outp_proj_folder = './Projects/editor_tf_fits/Data/Processed/tntnp/'
numpy_input_path = f'{outp_proj_folder}{exp_name}_FORMATTED.npy'
base_array = np.load(numpy_input_path)
print(type(base_array[0][0][0][0][0]))
print(f"Loaded array shape: {base_array.shape}") # 3d x Nc x calibration
calibration_slice = base_array[:, :, SLICE_TO_PLOT, :, 0]
mr_slice = base_array[:, :, SLICE_TO_PLOT, :, 1]
raise Exception()

if PLOT_RECON:
    # Visualization
    for i, calibration_name in enumerate(['Calibration', 'MR Scan']):
        arr = base_array[:, :, SLICE_TO_PLOT, :, i]# + 1j * base_array[:, :, SLICE_TO_PLOT, :, i]
        kspace_images = []
        image_titles = []
        recon_images = []
        recon_titles = []
        
        for detector in range(Nc):
            ksp = arr[:, :, detector]
            img_recon = np.fft.ifftshift(np.fft.ifft2(np.fft.ifftshift(ksp)))
            
            kspace_images.append(np.log1p(np.abs(ksp)))
            image_titles.append(f'{calibration_name} K-space Detector {detector + 1}')
            recon_images.append(np.abs(img_recon))
            recon_titles.append(f'{calibration_name} Image Detector {detector + 1}')
        
        plot_square_subplots(kspace_images, image_titles, f'{calibration_name} - K-space Slice {SLICE_TO_PLOT}', scale_param=0)
        plot_square_subplots(recon_images, recon_titles, f'{calibration_name} - Image Slice {SLICE_TO_PLOT}', scale_param=2)

    plt.show()


# here we want to compare EDITER  ... maybe can just use matlab
if EDITER_CALIBRATION_COMPARISON:
    pass








def evaluate_and_plot(model, x_test, y_test):
    model.eval()  # Set model to evaluation mode
    with torch.no_grad():
        NFE, Ns = x_test.shape[2], x_test.shape[3]  # Assuming x_test is (batch_size, channels, NFE, Ns)
        
        # Initialize an empty array to collect predictions
        y_predict = np.zeros_like(y_test)
        
        # Row-by-row evaluation
        for i in range(NFE):
            x_row = x_test[:, :, i:i+1, :]  # Select a single row (keep it as a 4D tensor)
            y_row_predict = model(x_row).cpu().numpy()  # Predict the row and convert to numpy
            y_predict[:, :, i:i+1, :] = y_row_predict  # Store the predicted row
            
        # Extracting the first image from the batch for visualization
        actual_image = y_test[0, 0].reshape(NFE, Ns)
        predicted_image = y_predict[0, 0].reshape(NFE, Ns)
        
        # Plot the actual vs predicted images
        plot_square_subplots([actual_image, predicted_image],
                             titles=["Actual Image", "Predicted Image"],
                             suptitle="Comparison of Actual vs Predicted",
                             color_map='gray')
        plt.show()


# here we want to train map for the dead trials 
if DL_CALIBRATION_COMPARISON:
    # calibration is now 256x40x4   
    Nfe = 40 # size of the blocks for the learning
    Ns = 3 # number of EMI sensing coils 
    Nbpr = 2 # blocks per frequency encode row

    calibration_slice = base_array[:, :, SLICE_TO_PLOT, :, 1]
    mr_slice = base_array[:, :, SLICE_TO_PLOT, :, 2]
    # calibration is now 256x40x4   
    # just implementing the basic full sized one
    calib_primary = calibration_slice[:, :, :1]
    calib_emi = calibration_slice[:, :, 1:]
    mr_primary = calibration_slice[:, :, :1]
    mr_emi = calibration_slice[:, :, 1:]

    model, calib_predict = train_calibration_model(calibration_slice, mr_slice)
