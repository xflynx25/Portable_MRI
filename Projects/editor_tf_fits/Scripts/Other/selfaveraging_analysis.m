%% File paths and parameters
clear all;
close all; 

projectdata = './Projects/editor_tf_fits/Data';
outpath = fullfile(projectdata, 'Processed/tnt','tnt_preprocessed_data_FORMATTED.mat'); % potentially bad due to the non-linear slice nature
%outpath = fullfile(projectdata, 'Processed/sai_data_example_3d.mat');

% 128 x 128 x 2 x 4
outpath = fullfile(projectdata, 'Processed/Cameleon/8642_FORMATTED_3d.mat');
%outpath = fullfile(projectdata, 'Processed/tnt','tnt_preprocessed_data_FORMATTED.mat'); % potentially bad due to the non-linear slice nature

%outpath = fullfile(projectdata, 'Processed/sai_data_example_3d.mat');


% good filepaths 
dataFilePath = fullfile(projectdata, 'Processed/sai_data_example_3d.mat');
dataFilePath = fullfile(projectdata, 'Processed/Cameleon/8598_FORMATTED_3d.mat');
%dataFilePath = fullfile(projectdata, 'Processed/tnt','tnt_preprocessed_data_FORMATTED.mat');
outpath = dataFilePath; 

outpath = fullfile(projectdata, 'Processed/homogenous_scanner/bluestoneFirst.mat');

% getting the name from the tnt
exp_name = 'zgrad_40gain_4coil_4avg_run1';
outpath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);

% public computer 
exp_name = '2Dsequence_2Dtable_averaging_singleecho_trigearly_4rx_1repeat_260_gain60_ball_day2aftershift_trial1';
exp_name = '2Dsequence_2Dtable_averaging_singleecho_4rx_1repeat_260_gain60_ball_day2trial1';
exp_name = '2Dsequence_2Dtable_averaging_singleecho_trigearly_4rx_1repeat_260_gain60_ball_day2aftershift_trial3';
exp_name = '2Dsequence_2Dtable_averaging_singleecho_trigearly_4rx_8repeat_260_gain60_ball_5th_trial1';
exp_name = '2Dsequence_2Dtable_calibration_singleecho_trigearly_4rx_1repeat_260_gain60_ball_5th_trial2'; 
%exp_name = 'builtin_averages';
outpath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);
%outpath = fullfile(projectdata, 'Processed/sai_data_example_3d.mat');

%% Parameters 
LINE_TO_PLOT_ECHO = 10; 
SLICE_TO_PLOT_ECHO = 11; 
SLICE_TO_PLOT_HISTOGRAM = 11; 
SNR_SLICE = 12;
PLOT_SLICE_NUM_ROWS = 3; 
HISTOGRAM_MINBINSIZE_FOR_PLOT = 5; 

Z_ACQUISITION_METHOD = 'cartesian'; %'phaseslice'; 

% SINGLETON Parameters
LINE_TO_PLOT_ECHO = 1; 
SLICE_TO_PLOT_ECHO = 1; 
SLICE_TO_PLOT_HISTOGRAM = 1; 
SNR_SLICE = 1;
PLOT_SLICE_NUM_ROWS = 4; 

% default params
noisecal = 1;
usephasecorrection = 0;
EMIacq = 1;
snrcalc = 1;
plot3d = 0; 
kspaceplots = 1; 
plot_histograms = 0; 

NUM_ACQUISITIONS = 2;
PLOT_SCALE = 2; 


%% Data exploration and visualization

% Extract primary data and EMI data
coil_data = load(outpath);
size(coil_data.datafft_combined)

raw_combined = sum(coil_data.datafft_combined, 5); 
avg_editer_ksp = zeros(size(coil_data.datafft_combined(:, :, :, :, 1)));

for ACQUISITION_NUMBER = 1:NUM_ACQUISITIONS
    disp('')
    disp(strcat('acq', num2str(ACQUISITION_NUMBER)))
    combined_data = coil_data.datafft_combined(:, :, :, :, ACQUISITION_NUMBER); 

    % Perform SNR calculation if enabled
    if snrcalc == 1
        % for raw
        initial =sum(coil_data.datafft_combined, 5); 

        primary_data = combined_data(:, :, :, 1);
        calculate_snr_saving(primary_data, SNR_SLICE, true);
        
    
        % for editor image 
        [I3D_Editer, corrected_ksp_3d] = Editer_3d_transform(combined_data, Z_ACQUISITION_METHOD); 
        calculate_snr_saving(corrected_ksp_3d, SNR_SLICE, true);

        % create the avg editor image
        avg_editer_ksp = avg_editer_ksp + corrected_ksp_3d;
    
        % Plot editer beast plot for each acq
        plot_emi_mitigation_slider_emiseperate_ksp(combined_data, PLOT_SLICE_NUM_ROWS, Z_ACQUISITION_METHOD, true, 1); 
        plot_emi_mitigation_slider_emiseperate(combined_data, PLOT_SLICE_NUM_ROWS, Z_ACQUISITION_METHOD, true, 2); 

    end
end

% ending SNR calc
if snrcalc == 1
    disp('combined, 1. raw, 2. classical averaging, 3. individual averaging')
    calculate_snr_saving(raw_combined, SNR_SLICE, true);

    % for editor image 
    [I3D_Editer, corrected_ksp_3d] = Editer_3d_transform(raw_combined, Z_ACQUISITION_METHOD); 
    calculate_snr_saving(corrected_ksp_3d, SNR_SLICE, true);

    calculate_snr_saving(avg_editer_ksp, SNR_SLICE, true);

    % plots
    I3Dfid = cartesian_3d_ifft(raw_combined(:, :, :, 1)); 
    I_raw = abs(I3Dfid(:, :, SNR_SLICE));
    classical = abs(I3D_Editer(:, :, SNR_SLICE));
    I3Dfid = cartesian_3d_ifft(avg_editer_ksp); 
    individual = abs(I3Dfid(:, :, SNR_SLICE));

    % Create a figure with 3 subplots
    figure;
    
    % Plot raw combined data
    subplot(1, 3, 1);
    plot_with_scale(I_raw, 'Raw Averaging on Combined', true, PLOT_SCALE);

    % Plot edited data
    subplot(1, 3, 2);
    plot_with_scale(classical, 'Classical (avg) method', true, PLOT_SCALE);

    % Plot average editor K-space data
    subplot(1, 3, 3);
    plot_with_scale(individual, 'Individual Method', true, PLOT_SCALE);


end