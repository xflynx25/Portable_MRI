% Add BM3D path (ensure the 'bm3d' folder is correctly specified)
addpath('bm3d');

% Experiment specifications   
imagename = 'cameraman256.png';

% Load noise-free image
y = im2double(imread(imagename));

% Generate blurry + noisy image
experiment_number = 4;

% Define blur and noise based on experiment number
if experiment_number == 4
    sigma = 7/255;
    v = [1 4 6 4 1]' * [1 4 6 4 1]; 
    v = v / sum(v(:));  % PSF
end

% Apply blur (if needed)
y_blur = imfilter(y, v(end:-1:1, end:-1:1), 'circular'); 

% Add noise
z = y_blur + sigma * randn(size(y_blur));

% Estimate noise sigma using MAD (Median Absolute Deviation)
sigma_est = estimate_noise_sigma_MAD(z);
fprintf('Estimated noise sigma: %.4f\n', sigma_est);

% Call BM3D with the estimated sigma (single output)
bm4d_image = BM3D(z, sigma_est, 'np');  % Using 'np' profile

% Calculate PSNR
psnr_val = getPSNR(y, bm4d_image);
fprintf('PSNR: %.2f dB\n', psnr_val);

% Plot the results
figure;
subplot(1, 3, 1);
imshow(y);
title('Original Image (y)');
subplot(1, 3, 2);
imshow(z);
title('Noisy Blurred Image (z)');
subplot(1, 3, 3);
imshow(bm4d_image);
title('Denoised Image (BM3D)');


plot_editer_advanced(z, bm4d_image, IMAGE_SCALE);