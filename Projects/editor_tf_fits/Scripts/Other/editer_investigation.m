% This script will try and elucidate the mysteries of editer
% Phase 1: what is being fit? 
% Phase 2: how do they work together (correlation analysis)
% Phase 2.5: how does it vary with parameters
% Phase 2.7: how does the previous fixed method, bijective function work
% Phase 3: are there any small adjustments that will improve it

% HYPERPARAMETERS
SLICE = 1; 
AVERAGE_NUMBER_FOR_INITIALVIS = 1; 
INITIAL_PLOT = 1; 
KSPACE_SCALE = 1; 
IMAGE_SCALE = 2; 
OLD_EDITER_ON = 0; 
REPEAT_NUMBER = 1;
close all; 

% DATA PATHS
projectdata = './Projects/editor_tf_fits/Data';
dataFilePath = fullfile(projectdata, 'Processed/Cameleon/8598_FORMATTED_3d.mat');

exp_name = 'zgrad_40gain_4coil_4avg_run1';
dataFilePath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);

exp_name = 'fulldataset_CCmode_noFilter_halbachcylinder_paperphantom_4Rx_singlegpa65_8avg_run1'; %'zgrad_40gain_4coil_4avg_run1';
dataFilePath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);

%exp_name = '2Dsequence_2Dtable_averaging_singleecho_trigearly_4rx_4repeat_260_gain60_ball_5th_trial1';
%exp_name = 'builtin_averages';
%exp_name = '2Dsequence_2Dtable_calibration_singleecho_trigearly_4rx_1repeat_260_gain60_ball_5th_trial2';
%exp_name = '2Dsequence_2Dtable_calibration_singleecho_trigearly_4rx_1repeat_260_gain60_ball_5th_trial2';


projectdata1 = './Projects/20240809/Data';
exp_name1 = 'with_blanket_test1'; 
exp_name1 = 'with_blanketgrounded_newgradOFF_doubleacquisition_test1'; 
%exp_name1 = 'with_blanketgrounded_newgradON_doubleacquisition_test1'; 
chosen_exp_name = exp_name1; 
chosen_folder_name = projectdata1; 
data_string = fullfile(chosen_folder_name, 'Raw', [chosen_exp_name, '.tnt']);
dataFilePath = fullfile(chosen_folder_name, 'Processed/tnt/',['tnt_preprocessed_data_', chosen_exp_name, '_FORMATTED.mat']);

% LOADING DATA AND PROCESSING INTO SINGLE SLICE (cd) coil data
data = load(dataFilePath);
combined_data = data.datafft_combined;
num_dimensions = length(size(combined_data));
disp(size(data.datafft_combined));
switch num_dimensions
    case 6 % repeats as well 
        if size(combined_data, 5) == 2 && AVERAGING == 0 % calibration without inplane averaging
            cd = squeeze(combined_data(:, :, SLICE, REPEAT_NUMBER, 2, :));
            calib_d = squeeze(combined_data(:, :, SLICE, REPEAT_NUMBER, 1, :));
        else
            if size(combined_data, 5) == 1
                cd = squeeze(combined_data(:, :, SLICE, REPEAT_NUMBER, 1, :));
                calib_d = cd; 
            else
                disp('fix hit averaging');
            end
        end
    otherwise
        fprintf('num_dimensions was %d', num_dimensions);
end 
disp(size(cd));
ksp_primary = cd(:, :, 1); 
ksp_emicoils = cd(:, :, 2:end);
raw_imgspace = cartesian_3d_ifft(cd);
num_coils = size(cd, 3); 


% INITIAL PLOT TO SEE WHAT WORKING WITH
if INITIAL_PLOT
    disp('Plotting initial vis...');
    figure;
    for i = 1:num_coils
        subplot(2, num_coils, i);
        plot_with_scale(abs(raw_imgspace(:, :, i)), sprintf('Image coil%d', i), true, IMAGE_SCALE);
    end 
    for i = 1:num_coils
        subplot(2, num_coils, 4 + i);
        plot_with_scale(abs(cd(:, :, i)), sprintf('ksp coil%d', i), true, KSPACE_SCALE);
    end 
end


% RUN EDITER, WITH CERTAIN PARAMS AND VISUALIZATIONS
W = 1; %number of PE per initial window
ksz_col_initial = 3; 
ksz_lin_initial = 0; 
correlation_eps = 5e-2; 
ksz_col_final = 7; 
ksz_lin_final = 0; 

cd_copy = cd; 
starter_kern_stack = devediter_initialfits(cd_copy, W, ksz_col_initial, ksz_lin_initial);
win_stack = devediter_correlationstage(cd_copy, starter_kern_stack, correlation_eps);
[kern_stack, win_stack, ksz_col, ksz_lin] = devediter_finalkernels(cd_copy, win_stack, ksz_col_final, ksz_lin_final);
%[corrected_img_dev, corrected_ksp_dev] = inference_editer2d(cd_copy, kern_stack, win_stack, ksz_col, ksz_lin);
[corrected_img_dev, corrected_ksp_dev] = devediter_inference(cd_copy, kern_stack, win_stack, ksz_col, ksz_lin);




% PLOTTING THE COMPARISONS
calibration = calib_d; 
mr_acquisition = cd; 

[kern_stack, win_stack, ksz_col, ksz_lin] = training_editer2d(calibration);
[corrected_img_calibration, corrected_ksp_calibration] = inference_editer2d(mr_acquisition, kern_stack, win_stack, ksz_col, ksz_lin);

% compare 
figure;
subplot(1, 4, 1);
rawifft = ifftshift(ifft2(ifftshift(ksp_primary)));
plot_with_scale(abs(rawifft), 'raw image', true, IMAGE_SCALE);

subplot(1, 4, 2);
plot_with_scale(abs(corrected_img_calibration), 'editer calib repeat on self', true, IMAGE_SCALE);

[I3D_Editer, corrected_ksp_3d] = Editer_2d_transform(mr_acquisition); 
subplot(1, 4, 3);
plot_with_scale(abs(I3D_Editer), 'Real Editer', true, IMAGE_SCALE);

subplot(1, 4, 4);
plot_with_scale(abs(corrected_img_dev), 'current editer', true, IMAGE_SCALE);



% SNRs, send in the primary (how does this make sense in the 3d case, the
% ifft of this kspace is still a kspace in the third dimension. 
disp('raw')
calculate_snr_saving2d(ksp_primary, true);

disp('typical editer')
calculate_snr_saving2d(corrected_ksp_3d(:, :, 1), true);

disp('calibration editer')
calculate_snr_saving2d(corrected_ksp_calibration(:, :, 1), true);

disp('dev editer')
calculate_snr_saving2d(corrected_ksp_dev(:, :, 1), true);



% REPEAT ACQUISITION ANALYSIS
cd1 = squeeze(combined_data(:, :, SLICE, 1, 1, :));
cd2 = squeeze(combined_data(:, :, SLICE, 2, 1, :));

imgrun1 = Editer_2d_transform(cd1); 
imgrun2 = Editer_2d_transform(cd2); 
erms = rms(abs(imgrun1(:) - imgrun2(:)));
fprintf('For Classical Editer');
fprintf('RMS Error (EMI Correction): %.4f\n', erms);
normalized_erms = rms(abs(imgrun1(:) - imgrun2(:)) / rms(abs(imgrun2(:))));
fprintf('Normalized RMS Error (EMI Correction): %.4f\n', normalized_erms);
