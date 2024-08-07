# need to take the matlab flattened csv and resave as a 5d numpy object which is equivalent to the matlab matrix
# data is complex

import numpy as np
import pandas as pd

# Define the CSV input path and the output path for the NumPy object
proj_folder = './Projects/editor_tf_fits/Data/Processed/tntcsv/'
exp_name = 'tnt_preprocessed_data_2Dsequence_2Dtable_calibration_singleecho_trigearly_4rx_1repeat_260_gain60_ball_5th_trial2'
csv_input_path = f'{proj_folder}{exp_name}_FORMATTED.csv'
numpy_output_path = f'{proj_folder}{exp_name}_FORMATTED.npy'

# Define the original shape of the data
ncol = 256 #frequency encode (readout)
nlin = 40 #excitations
nslc = 2 #echo train
Nc = 4 #detectors
n2d = 2 #calibrations or averages

# Load the CSV file into a 2D NumPy array
data_flat = pd.read_csv(csv_input_path).values

# Ensure the number of elements matches the expected size
expected_size = ncol * nlin * nslc * Nc * n2d
assert data_flat.size == expected_size, "Data size mismatch!"

# Reshape the 2D array into the original 5D shape
data_5d = data_flat.reshape((ncol, nlin, nslc, Nc, n2d))

# Save the 5D NumPy array to a file
np.save(numpy_output_path, data_5d)

print(f'Data has been successfully reshaped and saved to {numpy_output_path}')
