
% Comparing Stepwise Improvements 


% USER INPUT
scan_selector = 1; 
IMAGE_SCALE = 2; 
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
if scan_selector == 6 % blanket dirty ball 
    data_folder = 'BroadSNRperformance'; 
    experimentName = 'with_blanket_newgradON_test1_FORMATTED';
    Datadir = evalin('base', 'customDataDir');
end
pd = load(fullfile(Datadir, data_folder, [experimentName, '.mat'])).datafft_combined; %processed data
disp('loading ..., size')
size(pd)




% FORMATTING
disp('references')
if size(pd, 5) > 1
    cd = squeeze(pd(:, :, 1, 1, 2, :));
else
    cd = squeeze(pd(:, :, 1, 1, 1, :)); % when no calibration
end
plotCoilDataView2D(cd, IMAGE_SCALE, KSPACE_SCALE)
primary_ksp = cd(:, :, 1);
primary_img = shiftyifft(primary_ksp);
num_coils = size(pd, 6); 


% Define the range of ksz_col_initial and ksz_col_final
ksz_col_initial_values = [1, 3, 5, 7];
ksz_col_final_values = [1, 3, 5, 7];
ksz_col_initial_values = [0, 1, 3, 5];
ksz_col_final_values = [0, 1, 3, 5];
ksz_col_initial_values = [0, 1, 2, 4];
ksz_col_final_values = [0, 1, 2, 4];

ksz_col_initial_values = [1];
ksz_col_final_values = [1];
%ksz_col_initial_values = [0, 3];
%ksz_col_final_values = [0, 3];
num_values_i = length(ksz_col_initial_values);
num_values_f = length(ksz_col_final_values);

% Initialize a matrix to store SNR results
SNR_matrix = zeros(num_values_i, num_values_f);

% Other parameters
W = 1; % number of PE per initial window
ksz_lin_initial = 0; 
ksz_lin_final = 1; 
correlation_eps = 3e-1; 
MAX_KERNSTACK_TO_PLOT = 15; 
num_emi_coils = num_coils - 1;
mingroupingsize = 0; % 0 means use the line method
max_groupings = 1; 

% Save the current directory
cd_copy = cd; 
scan1 = squeeze(pd(:, :, 1, 1, 2, :)); 
scan2 = squeeze(pd(:, :, 1, 2, 2, :)); 
og1 = shiftyifft(scan1(:, :, 1)); %no support for calibration here 
og2 = shiftyifft(scan2(:, :, 1)); %no support for calibration here 


% allow to select the region by setting this to false
SNR = calculate_snr_saving2d(primary_img, false);

% the computes
[corrected_img_dev1, corrected_ksp_dev, MSE_dev] = devediter_full_autotuned_MSE(pd(:, :, :, :, 2, :), W, 1, 0, 1, 1, mingroupingsize, max_groupings);

[corrected_img_dev2, corrected_ksp_dev, SNR_dev] = devediter_full_autotuned_simplified(cd_copy, W, 1, 0, 1, 1, mingroupingsize, max_groupings);

editer1 = Editer_2d_transform(scan1);
editer2 = Editer_2d_transform(scan2);

emrs_og = rms(abs(og1(:) - og2(:)) / rms(abs(og2(:))));
erms_corrects = rms(abs(editer1(:) - editer2(:)) / rms(abs(editer2(:))));
boost_score = emrs_og / erms_corrects;

plot_editer_advanced(og1, corrected_img_dev1,IMAGE_SCALE );
plot_editer_advanced(og2, corrected_img_dev2,IMAGE_SCALE );
plot_editer_advanced(og1, editer1,IMAGE_SCALE );
plot_editer_advanced(og2, editer2,IMAGE_SCALE );

SNR_classical = calculate_snr_saving2d(editer1, true); 
MSE_classical = boost_score;

SNR_classical
SNR_dev
MSE_classical
MSE_dev