import os
import numpy as np
import matplotlib.pyplot as plt
from helpers.plotting import plot_square_subplots


# INPUTS 
##################

exp_name = 'tnt_preprocessed_data_2Dsequence_2Dtable_calibration_singleecho_trigearly_4rx_1repeat_260_gain60_ball_5th_trial2'

# Inputs
Nc = 4
SLICE_TO_PLOT = 1
PLOT_RECON = True
EDITER_CALIBRATION_COMPARISON = False
DL_CALIBRATION_COMPARISON = False


##################
##################
##################
##################


# LOADING 
outp_proj_folder = './Projects/editor_tf_fits/Data/Processed/tntnp/'
numpy_input_path = f'{outp_proj_folder}{exp_name}_FORMATTED.npy'
base_array = np.load(numpy_input_path)
print(f"Loaded array shape: {base_array.shape}")


if PLOT_RECON:
    # Visualization
    for i, calibration_name in enumerate(['Calibration', 'MR Scan']):
        arr = base_array[:, :, SLICE_TO_PLOT, :, i] + 1j * base_array[:, :, SLICE_TO_PLOT, :, i]
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

# here we want to train map for the dead trials 
if DL_CALIBRATION_COMPARISON:
    pass