import numpy as np
from scipy.io import loadmat


# INPUTS 
##################

exp_name = 'tnt_preprocessed_data_2Dsequence_2Dtable_calibration_singleecho_trigearly_4rx_1repeat_260_gain60_ball_5th_trial2'


##################
##################
##################
##################

# Define the MATLAB input path and the output path for the NumPy object
inp_proj_folder = './Projects/editor_tf_fits/Data/Processed/tnt/'
outp_proj_folder = './Projects/editor_tf_fits/Data/Processed/tntnp/'
mat_input_path = f'{inp_proj_folder}{exp_name}_FORMATTED.mat'
numpy_output_path = f'{outp_proj_folder}{exp_name}_FORMATTED.npy'

# Load the MATLAB file
mat_data = loadmat(mat_input_path)

# Extract the data array
if 'datafft_combined' in mat_data:
    data_array = mat_data['datafft_combined']
else:
    raise KeyError("The variable 'datafft_combined' is not found in the MATLAB file.")

# Verify the shape
print(f"Loaded data shape from MATLAB: {data_array.shape}")

# Save the data as a NumPy array
np.save(numpy_output_path, data_array)
print(f"Data saved to {numpy_output_path}")

# Verify the saved NumPy array
loaded_numpy_data = np.load(numpy_output_path)
print(f"Loaded data shape from NumPy file: {loaded_numpy_data.shape}")
