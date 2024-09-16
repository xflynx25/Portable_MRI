function [corrected_img, corrected_ksp] = devediter_full_autotuned(combined_data, W, ksz_col_initial, ksz_lin_initial, ...
    ksz_col_final, ksz_lin_final, max_groupings, test_points, mingroupsize)
    % like devediter_full but with better human understandable params
    % we want some relatively omniscent of the params, so want to find the
    % low and high where you get out of range, and take a random corr
    % thresh within this region
    % this means binary searches on each 
    % max_groupings: along with min as 1, how many groups you want as a max
    % test_points: once the viable cThresh range has been found, how many
    % to check
    % mingroupsize: if < 1, means use the first correlation method
    cd_copy = combined_data; 
    stop_epsilon = 1e-4; 
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
    cThresh_low = clow

    % find lowest cThresh that yields max_groupings
    % to allow for any over this continuum, we take the highest value in
    % the range as opposed to with 1, where there is only 1 way to fit all
    % to 1
    clow = 0; %-1? 
    chigh = 1; 
    while chigh - clow > stop_epsilon
        ctest = (clow + chigh) / 2; 
        
        starter_kern_stack = devediter_initialfits(cd_copy, W, ksz_col_initial, ksz_lin_initial);
        win_stack = correlation_method(cd_copy, starter_kern_stack, ctest);
        if size(win_stack, 1) > max_groupings + 1
            chigh = ctest; 
        else
            clow = ctest; 
        end
    end
    cThresh_high = clow
        
    
    % look over the test_points
    SNR_values = zeros(1, test_points);
    correlation_eps_values = linspace(cThresh_low, cThresh_high, test_points);
    for i = 1:test_points
        correlation_eps = correlation_eps_values(i);
        starter_kern_stack = devediter_initialfits(cd_copy, W, ksz_col_initial, ksz_lin_initial);
        win_stack = correlation_method(cd_copy, starter_kern_stack, correlation_eps);
        [kern_stack, win_stack, ksz_col, ksz_lin] = devediter_finalkernels(cd_copy, win_stack, ksz_col_final, ksz_lin_final);
        corrected_img = devediter_inference(cd_copy, kern_stack, win_stack, ksz_col, ksz_lin);
        SNR = calculate_snr_saving2d(corrected_img, true);
    
        % Store the SNR value
        SNR_values(i) = SNR;
    end
    
    % Plot the results
    figure;
    plot(correlation_eps_values, SNR_values, '-o');
    xlabel('Correlation Epsilon');
    ylabel('SNR');
    title('SNR vs Correlation Epsilon');
    
    % Find the maximum SNR and corresponding correlation_eps
    [max_SNR, max_idx] = max(SNR_values);
    best_correlation_eps = correlation_eps_values(max_idx);
    
    % Print the best SNR and corresponding correlation_eps
    fprintf('Best SNR: %f found with correlation_eps: %f\n', max_SNR, best_correlation_eps);

    throw('bobby')
    % use the best test_point and return the image


    starter_kern_stack = devediter_initialfits(cd_copy, W, ksz_col_initial, ksz_lin_initial);
    win_stack = devediter_correlationstage(cd_copy, starter_kern_stack, correlation_eps);
    num_groups = size(win_stack); 



    % Final kernel refinement stage
    [kern_stack, win_stack, ksz_col, ksz_lin] = devediter_finalkernels(cd_copy, win_stack, ksz_col_final, ksz_lin_final);

    % Inference stage to compute the corrected image and k-space
    [corrected_img, corrected_ksp] = devediter_inference(cd_copy, kern_stack, win_stack, ksz_col, ksz_lin);

    % Optionally, you can add visualizations or debugging information here
    % disp('Completed devEditer process.');

end
