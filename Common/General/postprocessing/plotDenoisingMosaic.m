function plotDenoisingMosaic(raw_data, reconstruct_raw_lambda, denoise_func_lambda, params, plot_scale)
    % plotDenoisingMosaic
    % Creates a mosaic plot showing the raw data and denoised images using various parameters.
    %
    % Usage:
    %   plotDenoisingMosaic(raw_data, reconstruct_raw_lambda, denoise_func_lambda, params, plot_scale)
    %
    % Inputs:
    %   raw_data               - The raw (noisy) image data (MxN or MxNxC).
    %   reconstruct_raw_lambda - A lambda (anonymous) function to process raw_data before plotting.
    %                            Example: @(x) abs(x), @(x) ifftshift(ifft2(x)), @(x) x
    %   denoise_func_lambda    - A lambda (anonymous) function that takes a parameter and returns a denoising function.
    %                            Example for BM3D: @(param) @(x) BM3D(x, param, 'np')
    %   params                 - An array of parameters (e.g., sigma values) to apply.
    %   plot_scale             - Scaling parameter(s) for plot_with_scale:
    %                            - Scalar: Same scale for all denoised images.
    %                            - Array: Individual scales for each denoised image.
    %
    % Example:
    %   sigma_guesses = [0.5, 1, 1.5, 2, 2.5] * sigma_est;
    %   denoise_func_lambda = @(param) @(x) BM3D(x, param, 'np');
    %   reconstruct_raw_lambda = @abs; % For complex k-space data
    %   plotDenoisingMosaic(z, reconstruct_raw_lambda, denoise_func_lambda, sigma_guesses, 0);
    
    % Validate Inputs
    narginchk(5, 5); % Ensure exactly five inputs are provided
    
    % Apply reconstruct_raw_lambda to raw_data
    processed_raw = reconstruct_raw_lambda(raw_data);
    
    % Ensure processed_raw is double and normalized to [0, 1]
    if ~isfloat(processed_raw)
        processed_raw = im2double(processed_raw);
    end
    processed_raw = mat2gray(processed_raw);
    
    % Number of parameters
    num_params = length(params);
    
    % Handle plot_scale
    if isscalar(plot_scale)
        scale_params = repmat(plot_scale, 1, num_params);
    elseif isvector(plot_scale) && length(plot_scale) == num_params
        scale_params = plot_scale;
    else
        error('plot_scale must be either a scalar or an array with the same length as params.');
    end
    
    % Preallocate cell array for denoised images
    denoised_images = cell(1, num_params);
    
    % Apply denoising function to processed_raw for each parameter
    fprintf('Applying denoising algorithm for %d parameters...\n', num_params);
    for i = 1:num_params
        fprintf('  Processing parameter %d/%d: %f...\n', i, num_params, params(i));
        denoise_func = denoise_func_lambda(params(i)); % Get the denoising function for current param
        denoised_image = denoise_func(processed_raw);   % Apply denoising
        denoised_images{i} = mat2gray(denoised_image); % Normalize denoised image
    end
    fprintf('Denoising completed.\n');
    
    % Determine grid size for mosaic (approximate square)
    total_images = 1 + num_params; % 1 for processed_raw + denoised_images
    grid_cols = ceil(sqrt(total_images));
    grid_rows = ceil(total_images / grid_cols);
    
    % Create a new figure for the mosaic
    figure('Name', 'Denoising Results Mosaic', 'NumberTitle', 'off', ...
           'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);
    
    % Plot Processed Raw Data
    subplot(grid_rows, grid_cols, 1);
    plot_with_scale(processed_raw, 'Raw Image', true, plot_scale); % scale_param = 0 (no scaling)
    
    % Plot Denoised Images
    for i = 1:num_params
        subplot(grid_rows, grid_cols, i + 1);
        plot_with_scale(denoised_images{i}, sprintf('Denoised (σ = %.3f)', params(i)), true, plot_scale);
    end
    
    % Add Super Title
    sgtitle('Denoising with Different Parameters', 'FontSize', 16, 'FontWeight', 'bold');
    
    % Enhance Layout
    set(gcf, 'Color', 'w'); % Set figure background to white
end
