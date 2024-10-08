% needs to take in a dimension 3 which has the calibration first then the
% editer 
function [corrected_img, corrected_ksp] = calibration2d_EDITER(combined_data, editer_options)
    calibration = squeeze(combined_data(:, :, 1, :));
    mr_acquisition = squeeze(combined_data(:, :, 2, :));

    [kern_stack, win_stack, ksz_col, ksz_lin] = devediter_training(calibration, editer_options); 
    [corrected_img, corrected_ksp] = devediter_inference(mr_acquisition, kern_stack, win_stack, ksz_col, ksz_lin);

end