function plotBM3DMosaic(original_img, noisy_img, sigma_list)
    % plotBM3DMosaic
    % Creates a mosaic plot showing the original, noisy, and BM3D-denoised images
    %
    % Usage:
    %   plotBM3DMosaic(original_img, noisy_img, sigma_list)
    %
    % Inputs:
    %   original_img - (Optional) Original noise-free image (MxN or MxNxC).
    %   noisy_img    - Noisy image to be denoised (MxN or MxNxC).
    %   sigma_list   - Array of sigma values for BM3D denoising.
    %
    % Example:
    %   plotBM3DMosaic(y, z, [0.5, 1, 1.5, 2, 2.5]);
    
    % Validate Inputs
    narginchk(2, 3);
    
    if nargin < 3
        error('Function requires at least three inputs: original_img, noisy_img, sigma_list.');
    end
    
    % Check if original_img is provided
    if isempty(original_img)
        include_original = false;
    else
        include_original = true;
    end
    
    % Ensure images are double and normalized to [0, 1]
    if ~isfloat(noisy_img)
        noisy_img = im2double(noisy_img);
    end
    noisy_img = mat2gray(noisy_img);
    
    if include_original
        if ~isfloat(original_img)
            original_img = im2double(original_img);
        end
        original_img = mat2gray(original_img);
    end
    
    % Number of sigma values
    num_sigmas = length(sigma_list);
    
    % Precompute denoised images
    y_est_all = cell(1, num_sigmas);
    fprintf('Denoising with BM3D for %d sigma values...\n', num_sigmas);
    for i = 1:num_sigmas
        fprintf('  Processing sigma = %.2f...\n', sigma_list(i));
        y_est_all{i} = BM3D(noisy_img, sigma_list(i), 'np');
        % Ensure denoised image is in [0, 1]
        y_est_all{i} = mat2gray(y_est_all{i});
    end
    fprintf('Denoising completed.\n');
    
    % Determine grid size for mosaic
    total_images = num_sigmas;
    if include_original
        total_images = total_images + 2; % Original and Noisy images
    else
        total_images = total_images + 1; % Only Noisy image
    end
    grid_size = ceil(sqrt(total_images));
    num_rows = grid_size;
    num_cols = ceil(total_images / num_rows);
    
    % Initialize cell array for mosaic
    mosaic_images = {};
    mosaic_titles = {};
    
    % Add Original Image
    if include_original
        mosaic_images{end+1} = original_img;
        mosaic_titles{end+1} = 'Original Image';
    end
    
    % Add Noisy Image
    mosaic_images{end+1} = noisy_img;
    mosaic_titles{end+1} = 'Noisy Image';
    
    % Add Denoised Images
    for i = 1:num_sigmas
        mosaic_images{end+1} = y_est_all{i};
        mosaic_titles{end+1} = sprintf('Denoised (σ = %.2f)', sigma_list(i));
    end
    
    % Create a figure
    figure('Name', 'BM3D Denoising Results', 'NumberTitle', 'off');
    
    % Plot each image in the grid
    for i = 1:length(mosaic_images)
        subplot(num_rows, num_cols, i);
        imshow(mosaic_images{i});
        title(mosaic_titles{i}, 'FontSize', 10);
    end
    
    % Adjust layout
    sgtitle('BM3D Denoising with Different \sigma Values', 'FontSize', 14);
end
