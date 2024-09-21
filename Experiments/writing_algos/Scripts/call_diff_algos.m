% this script used to write up the 4 main algos
%%% 1. EDITER nAVG
%%% 2. Calibration Classic
%%% 3. Calibration MultiLine
%%% 4. Calibration EDITER-Variant
% also used to write the metrics to evaluate
%%% 1. SNR
%%% 2. CNR
%%% 3. MSE
% we work on just one data point, then we can do experiments 

% we also want to allow augments, like the EDITER avg 

% loading
close all; %plots
data_folder = '80mT_Scanner/20240823'; 
experimentName = 'initial_scan_brain3_FORMATTED';
procDataDir = evalin('base', 'procDataDir');
pd = load(fullfile(procDataDir, data_folder, [experimentName, '.mat'])).datafft_combined; %processed data
disp('loading ..., size')
size(pd)

% VARS
IMAGE_SCALE = 3; 
KSPACE_SCALE = 0; 

% references 
disp('references')
%cd = squeeze(pd(:, :, 1, 1, 2, :));
cd = squeeze(pd(:, :, 1, 1, 1, :)); % when no calibration
plotCoilDataView2D(cd, IMAGE_SCALE, KSPACE_SCALE)
primary_ksp = cd(:, :, 1);
primary_img = shiftyifft(primary_ksp);


% EDITER classic, uses 2d
disp('EDITER classic, uses 2d');
[EDITER_img, EDITER_ksp] = Editer_2d_transform(cd); 
%plot_editer_advanced(primary_ksp, EDITER_ksp, KSPACE_SCALE);
plot_editer_advanced(primary_img, EDITER_img, IMAGE_SCALE);
throw('donezo for now')

% EDITER john-implementation (check same)
fprintf('\n\nEDITER john-implementation')
correlation_eps = 5e-2;
[devEDITER_img, devEDITER_ksp] = devediter_full(cd, 1, correlation_eps, 3,0,1,0); 
%plot_editer_advanced(primary_ksp, devEDITER_ksp, KSPACE_SCALE);
%plot_editer_advanced(primary_img, devEDITER_img, IMAGE_SCALE);

% adding in the SNR, CNR(not now), MSE, RMS error from the preversion. 
dim5 = 2;
emi_func = @(x) devediter_full(x, 1, correlation_eps, 3,0,1,0);
raw_func = @(x) shiftyifft(x); 
[SNR, intraRMS, interRMS] = repeat_evaluation(pd(:, :, :, :, dim5, :), emi_func, raw_func, false);



% EDITER n-avgs
fprintf('\n\nEDITER n-avgs independent')
N = 2; 
indices = [2,4,6,8];
indices = [2,4];
pdavg = slice_dimension(pd, indices, 5);

f = @(x) Editer_2d_transform(x); 
emi_func = @(x) apply_and_average(f, x, 3); 
fIDENTITY = @(x) shiftyifft(x); 
raw_func = @(x) apply_and_average(fIDENTITY, x, 3); 
%[SNR, intraRMS, interRMS] = repeat_evaluation(pdavg, emi_func, raw_func);



% EDITER n-avgs built in 
fprintf('\n\nEDITER n-avgs built in ')
index_groups = {[1,3,5,7], [2,4,6,8]};
reduced_array = clump_and_average(pd, index_groups, 5); 
preavg_calib = reduced_array(:, :, :, :, 1, :);
preavg_mr = reduced_array(:, :, :, :, 2, :);

emi_func = @(x) Editer_2d_transform(x); 
raw_func = @(x) shiftyifft(x); 
%[SNR, intraRMS, interRMS] = repeat_evaluation(preavg_mr, emi_func, raw_func);


% Look, we can compare an average over right next to each other and later 
fprintf('\n\navging next to vs later')
pd_avg_slice = slice_dimension(pd, [2,8], 5);
pd_repeat_slice = permute(pd_avg_slice, [1, 2, 3, 5, 4, 6]);%reverse them to simulate opposite

f = @(x) Editer_2d_transform(x); 
emi_func = @(x) apply_and_average(f, x, 3); 
fIDENTITY = @(x) shiftyifft(x); 
raw_func = @(x) apply_and_average(fIDENTITY, x, 3); 

%fprintf('\n\n NEAR AVERAGING')
%[SNR, intraRMS, interRMS] = repeat_evaluation(pd_avg_slice, emi_func, raw_func);
%fprintf('\n\n FAR AVERAGING')
%[SNR, intraRMS, interRMS] = repeat_evaluation(pd_repeat_slice, emi_func, raw_func);


% Calib EDITER 
fprintf('\n\nCalib EDITER ')
indices = [1,2];
pdavg = slice_dimension(pd, indices, 5); 
editer_options = struct(...
    'W', 1, ...
    'correlation_eps', 5e-2, ...
    'ksz_col_initial', 5, ...
    'ksz_lin_initial', 0, ...
    'ksz_col_final', 11, ...
    'ksz_lin_final', 0);
emi_func = @(x) calibration2d_EDITER(x, editer_options);
raw_func = @(x) shiftyifft(x(:, :, 2)); 
%[SNR, intraRMS, interRMS] = repeat_evaluation(pdavg, emi_func, raw_func);



% calibration with averaging
fprintf('\n\nCalibration with Averaging');
N = 2;  % Number of groups or calibration runs
total_raw1 = 0;
total_img1 = 0;
total_raw2 = 0;
total_img2 = 0;

for n = 1:N
    % Define the indices for each group
    indices = [-1 + 2 * n, 2 * n];
    
    % Slice the dimension and get the calibration data
    single_calib_run = slice_dimension(pd, indices, 5);
    
    % Perform the evaluation for each calibration run
    [raw1, img1, raw2, img2] = repeat_evaluation_quiet(single_calib_run, emi_func, raw_func);
    
    % Accumulate the results for averaging
    total_raw1 = total_raw1 + raw1;
    total_img1 = total_img1 + img1;
    total_raw2 = total_raw2 + raw2;
    total_img2 = total_img2 + img2;
end

% Average the accumulated results
avg_raw1 = total_raw1 / N;
avg_img1 = total_img1 / N;
avg_raw2 = total_raw2 / N;
avg_img2 = total_img2 / N;

% Call major_metrics on the averaged results
%[SNR, intraRMS, interRMS] = major_metrics(avg_raw1, avg_img1, avg_raw2, avg_img2, true);





% Calib classical 

original_options = struct(...
    'W', 40);

avy = slice_dimension(pd, [1,2], 5); 
avy = slice_dimension(avy, [1,3], 6); 
combined_data = squeeze(avy(:, :, 1, 1, :, :)); 
[corrected_img, corrected_ksp] = calibration2d_ORIGINAL(combined_data, original_options);
plot_editer_advanced(primary_img, corrected_img, 0); 
%plot_editer_advanced(primary_ksp, corrected_ksp, 0); 

%plotCoilDataView2D(squeeze(pd(:, :, 1, 1, 2, :)), 0, 0);
%plotCoilDataView2D(squeeze(pd(:, :, 1, 1, 1, :)), 0, 0);


emi_func = @(x) calibration2d_ORIGINAL(x, original_options);
raw_func = @(x) shiftyifft(x(:, :, 2)); 
[SNR, intraRMS, interRMS] = repeat_evaluation(avy, emi_func, raw_func);



% Calib classical multi-line





