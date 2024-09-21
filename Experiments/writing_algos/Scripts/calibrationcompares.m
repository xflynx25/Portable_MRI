% bar plot of different calibration approaches vs editer
% be able to select (loop select) dfferent scans
% for each, 
    % 1. call simple editer (single)
    % 2. call editer with average
    % 3. call calibration simple
    % 4. call calibration EDITER
 % plot them in bar graph
% becomes more complicated if we are too allow for MSE as well 
    % the main reason this is causing so much aversion is because the SNR
    % and MSE and Calbiraiton all requiring different data sizes so
    % spending lot of time doing this over and over. Probably should ahve
    % reorganized this somewhat to make easier. 


% USER INPUT
scan_selector = 1; 
IMAGE_SCALE = 2; 
KSPACE_SCALE = 0; 
%METRIC = 'SNR_editer'; 
SNRSQUARES_ALREADY_SET = false; 
calibration_trial = true; 

% LOADING, PREPARATION
close all; %plots
pd = read_in_common_dataset(scan_selector); 
num_coils = size(pd, 6); 
AVERAGE = size(pd, 5) > 2; 


mr_scans = pd(:, :, 1, 1:2, 1:2:end, :);
calib_scans = pd(:, :, 1, 1:2, 2:2:end, :);

mr_avg1_1 = squeeze(pd(:, :, 1, 1, 2, :));
mr_avg1_2 = squeeze(pd(:, :, 1, 2, 2, :));
calib_avg1_1 = squeeze(pd(:, :, 1, 1, 1, :));
calib_avg1_2 = squeeze(pd(:, :, 1, 2, 1, :));
if AVERAGE
    mr_avg2_1 = squeeze(pd(:, :, 1, 1, 4, :));
    mr_avg2_2 = squeeze(pd(:, :, 1, 2, 4, :));
    calib_avg2_1 = squeeze(pd(:, :, 1, 1, 3, :));
    calib_avg2_2 = squeeze(pd(:, :, 1, 2, 3, :));
end 

% set coords
calculate_snr_saving2d(shiftyifft(mr_avg1_1(:, :, 1)), SNRSQUARES_ALREADY_SET);


% TODO, PLOT SOME OF THESE SO WE KNOW LOOKING AT RIGHT THING
% Create a figure for the 2x4 plot
figure;

% Define the variables
variables = {mr_avg1_1, mr_avg1_2, mr_avg2_1, mr_avg2_2, calib_avg1_1, calib_avg1_2, calib_avg2_1, calib_avg2_2};
titles = {'MR Avg 1-1', 'MR Avg 1-2', 'MR Avg 2-1', 'MR Avg 2-2', 'Calib Avg 1-1', 'Calib Avg 1-2', 'Calib Avg 2-1', 'Calib Avg 2-2'};

% Loop through each variable and plot the absolute value of shiftyifft
for i = 1:8
    subplot(2, 4, i);
    % Perform the shiftyifft and take the absolute value
    transformed_img = abs(shiftyifft(variables{i}(:, :, 1)));
    
    % Plot the result
    imagesc(transformed_img);
    colormap('gray');
    axis image;  % Keep the aspect ratio
    title(titles{i});
end

% Add a colorbar to each plot for reference
colorbar;


% editer individual
[this_editer_img1, ~, SNR__editer_img1] = devediter_full_autotuned_simplified(mr_avg1_1, 1, 1, 0, 1, 1, 3, 10);
[this_editer_img2, ~, SNR__editer_img2]  = devediter_full_autotuned_simplified(mr_avg1_2, 1, 1, 0, 1, 1, 3, 10);
MSE_editer = MSE_ABS(this_editer_img1, this_editer_img2); 
%SNR_editer = mean([SNR__editer_img1, SNR__editer_img2]); 
SNR_editer = SNR__editer_img1;

% editer averaged
if AVERAGE
    this_editer_img1_2nd = devediter_full_autotuned_simplified(mr_avg2_1, 1, 1, 0, 1, 1, 3, 10);
    this_editer_img2_2nd = devediter_full_autotuned_simplified(mr_avg2_2, 1, 1, 0, 1, 1, 3, 10);
    
    % Pixel-wise averaging of the absolute values (use 2D averaging)
    this_editer_avg1 = (abs(this_editer_img1) + abs(this_editer_img1_2nd)) / 2; 
    this_editer_avg2 = (abs(this_editer_img2) + abs(this_editer_img2_2nd)) / 2; 
    
    % MSE and SNR for the averaged images
    MSE_editer_avg = MSE_ABS(this_editer_avg1, this_editer_avg2); 
    SNR_editer_avg = calculate_snr_saving2d(this_editer_avg1, true);
else
    SNR_editer_avg = SNR_editer; 
    MSE_editer_avg = MSE_editer;
end


% calibration og
original_options = struct(...
    'W', 1);
[kern_stack, win_stack] = linebyline_training(calib_avg1_1, original_options); 
ogcalib_1 = linebyline_inference(mr_avg1_1, kern_stack, win_stack);
[kern_stack, win_stack] = linebyline_training(calib_avg1_2, original_options); 
ogcalib_2 = linebyline_inference(mr_avg1_2, kern_stack, win_stack);

MSE_calibOG = MSE_ABS(ogcalib_1, ogcalib_2); 
SNR_calibOG = calculate_snr_saving2d(ogcalib_1, true);

% calibration editer 
% function needs to be made, input the caibration and mr component (maybe
% already exists)

% Calib EDITER 
fprintf('\n\nCalib EDITER ')
%[kern_stack, win_stack, ksz_col, ksz_lin] = calibrationtraining_full_autotuned_simplified(calib_avg1_1, 1, 1, 0, 1, 1, 3, 10);
%calib_img1 = devediter_inference(mr_avg1_1, kern_stack, win_stack, ksz_col, ksz_lin);
%[kern_stack, win_stack, ksz_col, ksz_lin] = calibrationtraining_full_autotuned_simplified(calib_avg1_2, 1, 1, 0, 1, 1, 3, 10);
%calib_img2 = devediter_inference(mr_avg1_2, kern_stack, win_stack, ksz_col, ksz_lin);

editer_options = struct(...
    'W', 1, ...
    'correlation_eps', 5e-2, ...
    'ksz_col_initial', 3, ...
    'ksz_lin_initial', 0, ...
    'ksz_col_final', 7, ...
    'ksz_lin_final', 0);

[kern_stack, win_stack, ksz_col, ksz_lin] = devediter_training(calib_avg1_1, editer_options);
calib_img1 = devediter_inference(mr_avg1_1, kern_stack, win_stack, ksz_col, ksz_lin);
[kern_stack, win_stack, ksz_col, ksz_lin] = devediter_training(calib_avg1_2, editer_options); 
calib_img2 = devediter_inference(mr_avg1_2, kern_stack, win_stack, ksz_col, ksz_lin);

MSE_calibEDITER = MSE_ABS(calib_img1, calib_img2); 
SNR_calibEDITER = calculate_snr_saving2d(calib_img1, true);


% Placeholder values for methods not yet computed
snr_values = [SNR_editer, SNR_editer_avg, SNR_calibOG, SNR_calibEDITER];
mse_values = [MSE_editer, MSE_editer_avg, MSE_calibOG, MSE_calibEDITER];
snr_values = [SNR_editer, SNR_editer_avg, SNR_calibEDITER];
mse_values = [MSE_editer, MSE_editer_avg, MSE_calibEDITER];

% Labels for the methods (for the bar plot)
method_names = {'Editer Individual', 'Editer Averaged', 'Calibration Simple', 'Calibration Editer'};

% Plot SNR bar plot
figure;
subplot(2,1,1);  % Upper plot for SNR
bar(snr_values);
title('SNR Comparison');
ylabel('SNR');
set(gca, 'XTickLabel', method_names);
xtickangle(45); % Rotate x labels for better visibility

% Plot MSE bar plot
subplot(2,1,2);  % Lower plot for MSE
bar(mse_values);
title('MSE Comparison');
ylabel('MSE');
set(gca, 'XTickLabel', method_names);
xtickangle(45);

% Optional: Set the axis limits for better visibility
ylim([0, max(mse_values) * 1.2]);


% Create a figure for the 2x3 plot
figure;

% Define the images and titles
images = {abs(this_editer_img1), abs(this_editer_img2), ...
          abs(this_editer_avg1), abs(this_editer_avg2), ...
          abs(ogcalib_1), abs(ogcalib_2), ...
          abs(calib_img1), abs(calib_img2)};
titles = {'Editer Individual Img1', 'Editer Individual Img2', ...
          'Editer Averaged Img1', 'Editer Averaged Img2', ...
          'Calibration OG Img1', 'Calibration OG Img2', ...
          'Calibration Editer Img1', 'Calibration Editer Img2'};

% Loop through each image and plot using plot_with_scale
for i = 1:8
    subplot(2, 4, i);
    scale_param = 1; % Adjust this as needed for scaling (e.g., 0 for default, or 0-1 range)
    square_plot = true; % Keep square aspect ratio
    plot_with_scale(images{i}, titles{i}, square_plot, scale_param);
end

% Optionally, adjust the layout to improve spacing
sgtitle('Comparison of Different Methods'); % Add a super title

figure; 
% Loop through each image and plot using plot_with_scale
for i = 1:4
    subplot(1, 4, i);
    scale_param = 1; % Adjust this as needed for scaling (e.g., 0 for default, or 0-1 range)
    square_plot = true; % Keep square aspect ratio
    plot_with_scale(images{2*i}, titles{2*i}, square_plot, scale_param);
end

