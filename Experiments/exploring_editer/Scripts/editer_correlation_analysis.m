% This script will try and elucidate the mysteries of editer (round 2)
% Phase 1: what is being fit? 
% Phase 2: how do they work together (correlation analysis)
% Phase 3: how does it vary with parameters


% USER INPUT
scan_selector = 1; 
IMAGE_SCALE = 1; 
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
    cd = squeeze(pd(:, :, 1, 1, 2, :));
else
    cd = squeeze(pd(:, :, 1, 1, 1, :)); % when no calibration
end
plotCoilDataView2D(cd, IMAGE_SCALE, KSPACE_SCALE)
primary_ksp = cd(:, :, 1);
primary_img = shiftyifft(primary_ksp);
num_coils = size(pd, 6); 
cd_copy = cd; 


% RUN EDITER, WITH CERTAIN PARAMS AND VISUALIZATIONS
W = 1; %number of PE per initial window
num_emi_coils = num_coils - 1;
ksz_lin_initial = 0; 
ksz_lin_final = 0; 

ksz_col_initial = 0; 
ksz_col_final = 0; 
correlation_eps = 9.4e-1; 
MAX_KERNSTACK_TO_PLOT = 15; 
mingroupingsize = 3; 

% 'individual', 'update1', 'mingroupings', 'singletf'
method = 'mingroupings'; 

% run initial fits and correlation stage
starter_kern_stack = devediter_initialfits(cd_copy, W, ksz_col_initial, ksz_lin_initial);
if strcmp(method, 'individual') == 1
    for idx = 1:size(cd_copy, 2)
        win_stack{idx} = idx;  % Replace each cell content with a single number
    end
end 
if strcmp(method, 'update1') == 1
    win_stack = devediter_correlationstage(cd_copy, starter_kern_stack, correlation_eps);
end
if strcmp(method, 'mingroupings') == 1
    win_stack = devediter_alternative_correlationstage(cd_copy, starter_kern_stack, correlation_eps, mingroupingsize);
end
if strcmp(method, 'singletf') == 1
    win_stack = devediter_alternative_correlationstage(cd_copy, starter_kern_stack, correlation_eps, size(cd_copy, 2));
end

% Display the groups
disp('Formed Groups:');
for i = 1:length(win_stack)
    fprintf('Group %d: %s\n', i, mat2str(win_stack{i}));
end

% finish, plot, calc snr
[kern_stack, win_stack, ksz_col, ksz_lin] = devediter_finalkernels(cd_copy, win_stack, ksz_col_final, ksz_lin_final);
[corrected_img_dev, corrected_ksp_dev] = devediter_inference(cd_copy, kern_stack, win_stack, ksz_col, ksz_lin);
plot_editer_advanced(primary_img, corrected_img_dev, IMAGE_SCALE);
SNR = calculate_snr_saving2d(corrected_img_dev, true)




