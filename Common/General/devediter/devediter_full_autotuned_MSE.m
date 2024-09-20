function [corrected_img, corrected_ksp, max_SNR] = devediter_full_autotuned_MSE(combined_data, W, ksz_col_initial, ksz_lin_initial, ...
    ksz_col_final, ksz_lin_final, mingroupsize, max_groupings)
    % this is going to just search over everything, so take max and min so
    % we dont have the long tails 
    scan1 = squeeze(combined_data(:, :, 1, 1, :, :)); 
    scan2 = squeeze(combined_data(:, :, 1, 2, :, :)); 
    cd_copy = scan1; % just use first one for the bounds section

    stop_epsilon = 1e-2; 
    if mingroupsize < 1
        correlation_method = @(data, kstack, c) devediter_correlationstage(data, kstack, c);
    else
        correlation_method = @(data, kstack, c) devediter_alternative_correlationstage(data, kstack, c, mingroupsize);
    end 

    % find highest cThresh that yields 1 group (b-search)
    clow = 0; %-1? 
    chigh = 1; 
    while chigh - clow > stop_epsilon
        ctest = (clow + chigh) / 2; 
        
        starter_kern_stack = devediter_initialfits(cd_copy, W, ksz_col_initial, ksz_lin_initial);
        win_stack = correlation_method(cd_copy, starter_kern_stack, ctest);
        if size(win_stack, 1) == 1
            clow = ctest; 
        else
            chigh = ctest; 
        end
    end
    cThresh_low = clow; 

    % find lowest cThresh that yields max groups (if maxgroups isn't
    % specified
    if isempty(max_groupings)
        starter_kern_stack = devediter_initialfits(cd_copy, W, ksz_col_initial, ksz_lin_initial);
        win_stack = correlation_method(cd_copy, starter_kern_stack, 1);
        max_groupings = size(win_stack, 1);
    end 
    max_groupings

    clow = 0; %-1? 
    chigh = 1; 
    while chigh - clow > stop_epsilon
        ctest = (clow + chigh) / 2; 
        
        starter_kern_stack = devediter_initialfits(cd_copy, W, ksz_col_initial, ksz_lin_initial);
        win_stack = correlation_method(cd_copy, starter_kern_stack, ctest);
        if size(win_stack, 1) >= max_groupings
            chigh = ctest; 
        else
            clow = ctest; 
        end
    end
    cThresh_high = chigh; 





    test_points = 30; 
        
    % look over the test_points
    SNR_values = zeros(1, test_points);
    correlation_eps_values = linspace(cThresh_low, cThresh_high, test_points);
    for i = 1:test_points

        % scan1
        correlation_eps = correlation_eps_values(i);
        starter_kern_stack = devediter_initialfits(scan1, W, ksz_col_initial, ksz_lin_initial);
        win_stack = correlation_method(scan1, starter_kern_stack, correlation_eps);
        [kern_stack, win_stack, ksz_col, ksz_lin] = devediter_finalkernels(scan1, win_stack, ksz_col_final, ksz_lin_final);
        corrected_img1 = devediter_inference(scan1, kern_stack, win_stack, ksz_col, ksz_lin);
        og1 = shiftyifft(scan1(:, :, 1)); %no support for calibration here 

        % scan2
        correlation_eps = correlation_eps_values(i);
        starter_kern_stack = devediter_initialfits(scan2, W, ksz_col_initial, ksz_lin_initial);
        win_stack = correlation_method(scan2, starter_kern_stack, correlation_eps);
        [kern_stack, win_stack, ksz_col, ksz_lin] = devediter_finalkernels(scan2, win_stack, ksz_col_final, ksz_lin_final);
        corrected_img2 = devediter_inference(scan2, kern_stack, win_stack, ksz_col, ksz_lin);
        og2 = shiftyifft(scan2(:, :, 1)); %no support for calibration here 

        emrs_og = rms(abs(og1(:) - og2(:)) / rms(abs(og2(:))));
        erms_corrects = rms(abs(corrected_img1(:) - corrected_img2(:)) / rms(abs(corrected_img2(:))));
        boost_score = emrs_og / erms_corrects;

        % can use SNR or between MSE as metric... if we use second, we need
        % to compute two images
    
        % Store the SNR value
        SNR_values(i) = boost_score;
    end
    
    % Plot the results
    if false
        figure;
        plot(correlation_eps_values, SNR_values, '-ok', 'LineWidth', 1.5, 'MarkerFaceColor', 'k');
        xlabel('Correlation Epsilon');
        ylabel('SNR');
        title('SNR vs Correlation Epsilon');
    end
    
    % Find the maximum SNR and corresponding correlation_eps
    SNR_values
    [max_SNR, max_idx] = max(SNR_values);
    best_correlation_eps = correlation_eps_values(max_idx);
    
    % Print the best SNR and corresponding correlation_eps
    fprintf('Best SNR: %f found with correlation_eps: %f\n', max_SNR, best_correlation_eps);


    % use the best test_point and return the image
    starter_kern_stack = devediter_initialfits(cd_copy, W, ksz_col_initial, ksz_lin_initial);
    win_stack = correlation_method(cd_copy, starter_kern_stack, best_correlation_eps);
    num_groups = size(win_stack)
    [kern_stack, win_stack, ksz_col, ksz_lin] = devediter_finalkernels(cd_copy, win_stack, ksz_col_final, ksz_lin_final);
    [corrected_img, corrected_ksp] = devediter_inference(cd_copy, kern_stack, win_stack, ksz_col, ksz_lin);

    % Optionally, you can add visualizations or debugging information here
    disp('Completed devEditer process.');

end
