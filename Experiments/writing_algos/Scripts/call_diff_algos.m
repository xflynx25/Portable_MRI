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
data_folder = '80mT_Scanner/20240807'; 
experimentName = 'calibration_doubleacq_4avgs_FORMATTED';
procDataDir = evalin('base', 'procDataDir');
pd = load(fullfile(procDataDir, data_folder, experimentName)).datafft_combined; %processed data
size(pd)

% VARS
IMAGE_SCALE = 1; 
KSPACE_SCALE = 0; 

% references 
cd = squeeze(pd(:, :, 1, 1, 2, :));
plotCoilDataView2D(cd, IMAGE_SCALE, KSPACE_SCALE)
primary_ksp = cd(:, :, 1);
primary_img = shiftyifft(primary_ksp);


% EDITER classic, uses 2d
size(cd)
[EDITER_img, EDITER_ksp] = Editer_2d_transform(cd); 
%plot_editer_advanced(primary_ksp, EDITER_ksp, KSPACE_SCALE);
%plot_editer_advanced(primary_img, EDITER_img, IMAGE_SCALE);

% EDITER john-implementation (check same)
correlation_eps = 5e-2;
[devEDITER_img, devEDITER_ksp] = devediter_full(cd, 1, correlation_eps, 3,0,1,0); 
%plot_editer_advanced(primary_ksp, devEDITER_ksp, KSPACE_SCALE);
%plot_editer_advanced(primary_img, devEDITER_img, IMAGE_SCALE);

% SNR, CNR, MSE, RMS error from the preversion.
cd2 = squeeze(pd(:, :, 1, 2, 2, :)); 
primary_ksp2 = cd2(:, :, 1);
primary_img2 = ifftshift(ifft2(ifftshift(primary_ksp2)));
plotCoilDataView2D(cd2, IMAGE_SCALE, KSPACE_SCALE)
[devEDITER2_img, devEDITER2_ksp] = devediter_full(cd2, 1, correlation_eps, 3,0,1,0); 
[SNR, intraRMS, interRMS] = major_metrics(primary_img, devEDITER_img, primary_img2, devEDITER2_img, false);


% EDITER n-avgs
N = 2; 
indices = [2,4,6,8];
pdavg = slice_dimension(pd, indices, 5);
size(pdavg)
cd = squeeze(pdavg(:, :, 1, 1, :, :));
cd2 = squeeze(pdavg(:, :, 1, 2, :, :));

f = @(x) Editer_2d_transform(x); 
result1 = apply_and_average(f, cd, 3);
result2 = apply_and_average(f, cd2, 3);
fIDENTITY = @(x) shiftyifft(x); 
og1 = apply_and_average(fIDENTITY, cd(:, :, :, 1), 3);
og2 = apply_and_average(fIDENTITY, cd2(:, :, :, 1), 3);

[SNR, intraRMS, interRMS] = major_metrics(og1, result1, og2, result2, true);



% Calib EDITER 
indices = [1,2];
pdavg = slice_dimension(pd, indices, 5);
cd = squeeze(pdavg(:, :, 1, 1, :, :));
cd2 = squeeze(pdavg(:, :, 1, 2, :, :));
editer_options = struct(...
    'W', 1, ...
    'correlation_eps', 5e-2, ...
    'ksz_col_initial', 5, ...
    'ksz_lin_initial', 0, ...
    'ksz_col_final', 11, ...
    'ksz_lin_final', 0);
[calibrationEDITER_corrected_img, calibrationEDITER_corrected_ksp] = calibration2d_EDITER(cd, editer_options);
[calibrationEDITER_corrected_img2, calibrationEDITER_corrected_ksp2] = calibration2d_EDITER(cd2, editer_options);
[SNR, intraRMS, interRMS] = major_metrics(primary_img, calibrationEDITER_corrected_img, primary_img2, calibrationEDITER_corrected_img2, true);


% Calib classical 


% Calib classical multi-line





