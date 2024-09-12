function [kern_stack, win_stack, ksz_col, ksz_lin] = devediter_training(calibration, editer_options)
    
    %unpack
    cd_copy = calibration; 
    W = editer_options.W;
    correlation_eps = editer_options.correlation_eps;
    ksz_col_initial = editer_options.ksz_col_initial;
    ksz_lin_initial = editer_options.ksz_lin_initial;
    ksz_col_final = editer_options.ksz_col_final;
    ksz_lin_final = editer_options.ksz_lin_final;

    % Initial fitting stage
    starter_kern_stack = devediter_initialfits(cd_copy, W, ksz_col_initial, ksz_lin_initial);

    % Correlation stage
    win_stack = devediter_correlationstage(cd_copy, starter_kern_stack, correlation_eps);

    % Final kernel refinement stage
    [kern_stack, win_stack, ksz_col, ksz_lin] = devediter_finalkernels(cd_copy, win_stack, ksz_col_final, ksz_lin_final);

end
