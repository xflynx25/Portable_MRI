% so now we are doing the initial method, line by line full fits 
function [corrected_img, corrected_ksp] = calibration2d_ORIGINAL(combined_data, original_options)
    calibration = squeeze(combined_data(:, :, 1, :));
    mr_acquisition = squeeze(combined_data(:, :, 2, :));

    [kern_stack, win_stack] = linebyline_training(calibration, original_options); 
    [corrected_img, corrected_ksp] = linebyline_inference(mr_acquisition, kern_stack, win_stack);
end