%% File paths and parameters
clear all;
close all; 

projectdata = './Projects/editor_tf_fits/Data';
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
snrcalc = 0;
plot3d = 0; 
kspaceplots = 1; 
plot_histograms = 0; 

NUM_ACQUISITIONS = 2;
PLOT_SCALE = 4; 
EDITER_CALIBRATION_ON = 1; 
CALIBRATION_ONE_AVERAGE = 0; 
AVERAGING_ANALYSIS = 0; 


%% Data exploration and visualization

% Extract primary data and EMI data
cd = load(outpath);
coil_data = cd.datafft_combined; 
size(coil_data)

calibration_sequence = coil_data(:, :, :, :, 1); 
mr_sequence = coil_data(:, :, :, :, 2); 
mr_doubled = repmat(mr_sequence, [1,1,1,1,2]);
if CALIBRATION_ONE_AVERAGE
    coil_data = mr_doubled; % if calibration sequence
end

raw_combined = sum(coil_data, 5); 
avg_editer_ksp = zeros(size(mr_sequence));


%% COMPUTING EDITER ON AVERAGES
if AVERAGING_ANALYSIS
    for ACQUISITION_NUMBER = 1:NUM_ACQUISITIONS
        disp('')
        disp(strcat('acq', num2str(ACQUISITION_NUMBER)))
        combined_data = coil_data(:, :, :, :, ACQUISITION_NUMBER); 
    
        % Perform SNR calculation if enabled
        if snrcalc == 1
            % for raw
            initial =sum(coil_data, 5); 
    
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
end

%% PLOTTING
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

%% use the model trained on the calibration to do inference on the MR
% acquisition (requires editer file to be split and return the params)
if EDITER_CALIBRATION_ON == 1 
    mr_plane = squeeze(mr_sequence(:, :, SNR_SLICE, :)); 
    calibration_plane = squeeze(calibration_sequence(:, :, SNR_SLICE, :)); 
    size(mr_plane)

    [kern_stack, win_stack, ksz_col, ksz_lin] = training_editer2d(calibration_plane);
    [corrected_img_calibration, corrected_ksp_calibration] = inference_editer2d(mr_plane, kern_stack, win_stack, ksz_col, ksz_lin);

    % compare 
    figure;
    subplot(1, 3, 1);
    rawifft = cartesian_3d_ifft(mr_sequence); 
    plot_with_scale(abs(rawifft(:, :, SNR_SLICE)), 'raw image', true, PLOT_SCALE);

    subplot(1, 3, 2);
    plot_with_scale(abs(corrected_img_calibration), 'editer calib repeat on self', true, PLOT_SCALE);

    [I3D_Editer, corrected_ksp_3d] = Editer_2d_transform(mr_plane); 
    subplot(1, 3, 3);
    plot_with_scale(abs(I3D_Editer), 'Real Editer', true, PLOT_SCALE);



    % SNRs, send in the primary
    disp('raw')
    calculate_snr_saving(mr_sequence(:, :, :, 1), SNR_SLICE, true);

    disp('typical editer')
    calculate_snr_saving(corrected_ksp_3d, SNR_SLICE, true);

    disp('calibration editer')
    calculate_snr_saving(corrected_ksp_calibration, SNR_SLICE, true);
end