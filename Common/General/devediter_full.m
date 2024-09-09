function [corrected_img, corrected_ksp] = devediter_full(combined_data, W, correlation_eps, ksz_col_initial, ksz_lin_initial, ksz_col_final, ksz_lin_final)
    % DEVEDITER_FULL: Runs the complete devEditer process
    %
    % Inputs:
    % - cd: Coil data (3D or 4D array)
    % - W: Number of PE per initial window
    % - ksz_col_initial: Initial kernel size (columns)
    % - ksz_lin_initial: Initial kernel size (lines)
    % - correlation_eps: Correlation epsilon threshold
    % - ksz_col_final: Final kernel size (columns)
    % - ksz_lin_final: Final kernel size (lines)
    %
    % Outputs:
    % - corrected_img: Corrected image after processing
    % - corrected_ksp: Corrected k-space data

    % Make a copy of the input coil data
    cd_copy = combined_data; 

    % Initial fitting stage
    starter_kern_stack = devediter_initialfits(cd_copy, W, ksz_col_initial, ksz_lin_initial);

    % Correlation stage
    win_stack = devediter_correlationstage(cd_copy, starter_kern_stack, correlation_eps);

    % Final kernel refinement stage
    [kern_stack, win_stack, ksz_col, ksz_lin] = devediter_finalkernels(cd_copy, win_stack, ksz_col_final, ksz_lin_final);

    % Inference stage to compute the corrected image and k-space
    [corrected_img, corrected_ksp] = devediter_inference(cd_copy, kern_stack, win_stack, ksz_col, ksz_lin);

    % Optionally, you can add visualizations or debugging information here
    % disp('Completed devEditer process.');

end
