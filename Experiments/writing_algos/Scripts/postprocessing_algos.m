% this script used to write up the 3 main postprocessing algos (4 if time)
% 1. BM3D
% 2. NLM
% 3. TV
% 4. ADF 
% we can do combinations as well, can compare to editer 


% USER INPUT
scan_selector = 5; 
IMAGE_SCALE = 12; 
KSPACE_SCALE = 0; 


% LOADING, PREPARATION
close all; %plots
if scan_selector == 1 % SOOO NOISY brain
    data_folder = '80mT_Scanner/20240823'; 
    experimentName = 'brain_calibration_repeat2D_newgradON_trial1_FORMATTED';
    Datadir = evalin('base', 'procDataDir');
end
if scan_selector == 2 % cleaner brain
    data_folder = '80mT_Scanner/20240823'; 
    experimentName = 'brain_calibration_repeat2D_FORMATTED';
    Datadir = evalin('base', 'procDataDir');
end
if scan_selector == 3 % clean distorted ball
    data_folder = '80mT_Scanner/20240823'; 
    experimentName = 'initial_scan_ball7_FORMATTED';
    Datadir = evalin('base', 'procDataDir');
end
if scan_selector == 4 % clean decent ball
    data_folder = '80mT_Scanner/20240807'; 
    experimentName = 'calibration_doubleacq_2avgs_FORMATTED';
    Datadir = evalin('base', 'procDataDir');
end
if scan_selector == 5 % the broad snr dataset stuff
    data_folder = 'BroadSNRperformance'; 
    experimentName = '8642_FORMATTED';
    Datadir = evalin('base', 'customDataDir');
end

pd = load(fullfile(Datadir, data_folder, [experimentName, '.mat'])).datafft_combined; %processed data
disp('loading ..., size')
size(pd)


% FORMATTING
disp('references')
if size(pd, 5) > 1
    pdmrswoop = pd(:, :, :, :, 2, :);
    cd = squeeze(pd(:, :, 1, 1, 2, :));
else
    pdmrswoop = pd(:, :, :, :, 1, :);
    cd = squeeze(pd(:, :, 1, 1, 1, :)); % when no calibration
end
plotCoilDataView2D(cd, IMAGE_SCALE, KSPACE_SCALE)
primary_ksp = cd(:, :, 1);
primary_img = shiftyifft(primary_ksp);


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
%plotDenoisingMosaic(EDITER_img, reconstruct_raw_lambda, denoise_func_lambda, sigma_guesses, IMAGE_SCALE);

% compare the SNRs
% raw bm4d
fprintf('\n\nBM4D\n');

emi_func = @(x) BM3D(abs(shiftyifft(x(:, :, 1))), sigma_est_solo, 'np');
raw_func = @(x) shiftyifft(x); 
[SNR, intraRMS, interRMS] = repeat_evaluation(pdmrswoop, emi_func, raw_func, true);

% editer
fprintf('\n\nEDITER\n');
emi_func = @(x) Editer_2d_transform(x);
raw_func = @(x) shiftyifft(x); 
[SNR, intraRMS, interRMS] = repeat_evaluation(pdmrswoop, emi_func, raw_func, true);

% combined
fprintf('\n\nCOMBINED\n');
emi_func = @(x) BM3D(abs(Editer_2d_transform(x)), sigma_est_editer, 'np');
raw_func = @(x) shiftyifft(x); 
[SNR, intraRMS, interRMS] = repeat_evaluation(pdmrswoop, emi_func, raw_func, true);


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
nlm_max = .15;
nlm_guesses = linspace(nlm_min, nlm_max, num_points);

% For TV
tv_middle = 0.05; % Adjust based on your data
tv_min = 0.01;
tv_max = 0.1;
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

fprintf('\n\nTV\n');
emi_func = @(x) imdiffusefilt(abs(shiftyifft(x(:, :, 1))), ...
    'ConductionMethod', 'exponential', ...
    'GradientThreshold', .055, ...
    'NumberOfIterations', 5); % Fixed number of iterations
raw_func = @(x) shiftyifft(x); 
[SNR, intraRMS, interRMS] = repeat_evaluation(pdmrswoop, emi_func, raw_func, true);
