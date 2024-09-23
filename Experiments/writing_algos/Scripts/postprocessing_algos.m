% this script used to write up the 3 main postprocessing algos (4 if time)
% 1. BM3D
% 2. NLM
% 3. TV
% 4. ADF 
% we can do combinations as well, can compare to editer 


% USER INPUT
scan_selector = 2; 
IMAGE_SCALE = 2; 
KSPACE_SCALE = 0; 
SNRSQUARES_ALREADY_SET = true; 
calibration_trial = true; 

% LOADING, PREPARATION
close all; %plots
pd = read_in_common_dataset(scan_selector); 
num_coils = size(pd, 6); 



% FORMATTING
disp('references')
if calibration_trial
    pdmrswoop = pd(:, :, :, :, 2, :);
    cd = squeeze(pd(:, :, 1, 1, 2, :));
else
    pdmrswoop = pd(:, :, :, :, 1, :);
    cd = squeeze(pd(:, :, 1, 1, 1, :)); % when no calibration
end
plotCoilDataView2D(cd, IMAGE_SCALE, KSPACE_SCALE)
primary_ksp = cd(:, :, 1);
primary_img = shiftyifft(primary_ksp);

% need to double up the pdmrswoop if only one example for consistency
if size(pdmrswoop, 4) < 2
    pdmrswoop = cat(4, pdmrswoop, pdmrswoop);  % Duplicate the data along the third dimension
end


calculate_snr_saving2d(shiftyifft(cd(:, :, 1)), SNRSQUARES_ALREADY_SET);



% BM4D
% Use MAD estimation method to determine the points for sigma guesses
sigma_est_solo = estimate_noise_sigma_MAD(abs(primary_img));
fprintf('Estimated noise sigma: %.4f\n', sigma_est_solo);
sigma_guesses = [0.5, 1, 1.5, 2, 2.5] * sigma_est_solo;

% visualize the parameter variation
reconstruct_raw_lambda = @(x) abs(x); 
denoise_func_lambda = @(param) @(x) BM3D(abs(x), param, 'np'); 
%plotDenoisingMosaic(primary_img, reconstruct_raw_lambda, denoise_func_lambda, sigma_guesses, IMAGE_SCALE);







% EDITER CLASSIC
disp('EDITER classic, uses 2d');
[EDITER_img, EDITER_ksp] = Editer_2d_transform(cd); 
%plot_editer_advanced(primary_ksp, EDITER_ksp, KSPACE_SCALE);
plot_editer_advanced(primary_img, EDITER_img, IMAGE_SCALE);




% BM4D ON EDITER (combo)
sigma_est_editer = estimate_noise_sigma_MAD(abs(EDITER_img));
fprintf('Estimated noise sigma: %.4f\n', sigma_est_editer);
sigma_guesses = [0.5, 1, 1.5, 2, 2.5] * sigma_est_editer;
reconstruct_raw_lambda = @(x) abs(x); 
denoise_func_lambda = @(param) @(x) BM3D(abs(x), param, 'np'); 
plotDenoisingMosaic(EDITER_img, reconstruct_raw_lambda, denoise_func_lambda, sigma_guesses, IMAGE_SCALE);
    sgtitle('BM3D Denoising', 'FontSize', 16, 'FontWeight', 'bold');

% compare the SNRs
% raw bm4d
fprintf('\n\nBM4D\n');

emi_func = @(x) BM3D(abs(shiftyifft(x(:, :, 1))), sigma_est_solo, 'np');
raw_func = @(x) shiftyifft(x); 
[SNR, intraRMS, interRMS] = repeat_evaluation(pdmrswoop, emi_func, raw_func, true);
SNR

% editer
fprintf('\n\nEDITER\n');
emi_func = @(x) Editer_2d_transform(x);
raw_func = @(x) shiftyifft(x); 
[SNR, intraRMS, interRMS] = repeat_evaluation(pdmrswoop, emi_func, raw_func, true);
SNR

% combined
fprintf('\n\nCOMBINED\n');
emi_func = @(x) BM3D(abs(Editer_2d_transform(x)), sigma_est_editer, 'np');
raw_func = @(x) shiftyifft(x); 
[SNR, intraRMS, interRMS] = repeat_evaluation(pdmrswoop, emi_func, raw_func, true);
SNR


% Try with other algos
% Define parameter ranges
% For NLM: DegreeOfSmoothing typically between 0.1 and 3
% For TV: Convergence typically between 0.01 and 0.1

% Number of interpolation points
num_points = 5;

% Define ranges centered around a middle point
% For NLM
nlm_middle = 0.5; % Adjust based on your data
nlm_min = 0.01;
nlm_max = .05;
nlm_guesses = linspace(nlm_min, nlm_max, num_points);

% For TV
tv_middle = 0.05; % Adjust based on your data
tv_min = 0.01;
tv_max = 0.07;
tv_guesses = linspace(tv_min, tv_max, num_points);

% Define Reconstruct Raw Lambda (Identity for image space)
reconstruct_identity = @(x) x; 
denoise_func_lambda_NLM = @(param) @(x) imnlmfilt(x, 'DegreeOfSmoothing', param);
denoise_func_lambda_TV = @(param) @(x) imdiffusefilt(x, ...
    'ConductionMethod', 'exponential', ...
    'GradientThreshold', param, ...
    'NumberOfIterations', 5); % Fixed number of iterations

% Plot NLM Results
plotDenoisingMosaic(abs(primary_img), reconstruct_identity, denoise_func_lambda_NLM, nlm_guesses, IMAGE_SCALE);
sgtitle('NLM Denoising', 'FontSize', 16, 'FontWeight', 'bold');
% Plot TV Results
plotDenoisingMosaic(abs(primary_img), reconstruct_identity, denoise_func_lambda_TV, tv_guesses, IMAGE_SCALE);
    sgtitle('TV Denoising', 'FontSize', 16, 'FontWeight', 'bold');

% plot snrs
fprintf('\n\nNLM\n');
emi_func = @(x) imnlmfilt(abs(shiftyifft(x(:, :, 1))), 'DegreeOfSmoothing', .08);
raw_func = @(x) shiftyifft(x); 
[SNR, intraRMS, interRMS] = repeat_evaluation(pdmrswoop, emi_func, raw_func, true);
SNR

fprintf('\n\nTV\n');
emi_func = @(x) imdiffusefilt(abs(shiftyifft(x(:, :, 1))), ...
    'ConductionMethod', 'exponential', ...
    'GradientThreshold', .055, ...
    'NumberOfIterations', 5); % Fixed number of iterations
raw_func = @(x) shiftyifft(x); 
[SNR, intraRMS, interRMS] = repeat_evaluation(pdmrswoop, emi_func, raw_func, true);
SNR






% Apply smoothing functions to both primary_img and EDITER_img
absprimary = abs(primary_img); 
absediter = abs(EDITER_img); 

gradient_threshold = .1; 
nlm_smoothing = .08; 
sigmaprimary = estimate_noise_sigma_MAD(absprimary)
sigmaediter = estimate_noise_sigma_MAD(absediter)
sigmaediter = sigmaprimary


primary_NLM = smoothNLM(absprimary, nlm_smoothing);
primary_TV = smoothTV(absprimary, gradient_threshold);
primary_BM3D = smoothBM3D(absprimary, sigmaprimary);

EDITER_NLM = smoothNLM(absediter, nlm_smoothing);
EDITER_TV = smoothTV(absediter, gradient_threshold);
EDITER_BM3D = smoothBM3D(absediter, sigmaediter);

% Create a 2x4 plot
figure;

% Define the images and titles for the plot
images = {absprimary, primary_NLM, primary_TV, primary_BM3D, ...
          absediter, EDITER_NLM, EDITER_TV, EDITER_BM3D};
titles = {'Primary Image', 'Primary NLM', 'Primary TV', 'Primary BM3D', ...
          'EDITER Image', 'EDITER NLM', 'EDITER TV', 'EDITER BM3D'};


% Initialize an array to store the SNR values
SNR_values = zeros(1, length(images));

% Loop through each image and calculate the SNR
for i = 1:length(images)
    SNR_values(i) = calculate_snr_saving2d(images{i}, true);
end

% Display the SNR values
disp('SNR values for each image:');
disp(SNR_values);


% Loop through each image and plot using plot_with_scale
for i = 1:8
    subplot(2, 4, i);
    square_plot = true; % Keep square aspect ratio
    plot_with_scale(images{i}, titles{i}, square_plot, IMAGE_SCALE);
end

% Add a super title to the figure
sgtitle('Primary and EDITER Images with Smoothing Transforms');

