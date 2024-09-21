
% USER INPUT
scan_selector = 11; 
IMAGE_SCALE = 2; 
KSPACE_SCALE = 0; 
METRIC = 'SNR_base'; 
%METRIC = 'SNR_editer'; 
SNRSQUARES_ALREADY_SET = false; 
calibration_trial = true; 
REPEAT_NUMBER = 1; 
METHOD = 'MSE'; 

% LOADING, PREPARATION
close all; %plots
pd = read_in_common_dataset(scan_selector); 


% FORMATTING
disp('references')
if size(pd, 5) > 1 & calibration_trial
    cd = pd(:, :, 1, REPEAT_NUMBER, 2:2:end, :); % every two 
else
    cd = pd(:, :, 1, REPEAT_NUMBER, 1:end, :); % every one 
end
plotCoilDataView2D(cd, IMAGE_SCALE, KSPACE_SCALE)
primary_ksp = cd(:, :, 1);
primary_img = shiftyifft(primary_ksp);
num_coils = size(pd, 6); 

% set coords
calculate_snr_saving2d(primary_img, SNRSQUARES_ALREADY_SET);

% now lets check the averages. We want to make a line plot with three
% things
% we need to go through axes 4 and 5
% and we plot raw, repeat(4), and consecutive (5), 
% so for example, we are going to hood 5 at just the 1st, and then go
% through dimension 4
% for raw we plot the actual value with the matrix, and for repeat we keep a running
% average of the matrices, and plott the value of that. 
% when we are done with dimension 4, we go through dimension 5, and repeat,
% although we have already done the raw so just are doing the consecutive 
% and the thing we plot for each one is a function metric(arr) which takes
% in the array and gets some sort of metric (like SNR), for now you can
% assume i have written this

disp(size(cd))

% Loop through axes 4 and 5 for raw, repeat, and consecutive plots
figure;
hold on;
% Initialize arrays for metrics
raw_metrics = []; % Raw metrics
raw_metrics_editer = []; % Raw metrics
averaged_metrics = []; % Raw metrics
averaged_metrics_editer = []; % Raw metrics
editer_individual = []; % Raw metrics

if METHOD == 'SNR'
    editers = zeros(size(cd, 1), size(cd, 2), size(cd, 5)); 
    for dim5 = 1:size(cd, 5)
        raw_value = cd(:, :, 1, 1, dim5, :); % Raw matrix for dim5
        SNR_raw = metric(raw_value, 'SNR_base');
    
        [this_editer_img, ~, SNR_editer] = devediter_full_autotuned_simplified(squeeze(raw_value), 1, 1, 0, 1, 1, 3, 10);
        %[this_editer_img, ~, SNR_editer] = devediter_full_autotuned_simplified(squeeze(raw_value), 1, 0, 0, 7, 0, 3, 10);
    
        averaged_ksp = mean(cd(:, :, 1, dim4, 1:dim5, :), 5); 
        SNR_averaged = metric(averaged_ksp, 'SNR_base');
    
        [averaged_editer_img, ~, SNR_averaged_editer] = devediter_full_autotuned_simplified(squeeze(averaged_ksp), 1, 1, 0, 1, 1, 3, 10);
        %[averaged_editer_img, ~, SNR_averaged_editer] = devediter_full_autotuned_simplified(squeeze(averaged_ksp), 1, 0, 0, 7, 0, 3, 10);
    
        editers(:, :, dim5) = this_editer_img; 
        individuals_avged = sum(editers, 3) / dim5;
        SNR_individual = calculate_snr_saving2d(individuals_avged, true);
    
    
    
        raw_metrics = [raw_metrics; SNR_raw];
        raw_metrics_editer = [raw_metrics_editer; SNR_editer];
        averaged_metrics = [averaged_metrics; SNR_averaged];
        averaged_metrics_editer = [averaged_metrics_editer; SNR_averaged_editer];
        editer_individual = [editer_individual; SNR_individual];
    end
else %metric MSE
    if size(pd, 5) > 1 & calibration_trial
        cd = pd(:, :, 1, 1:2, 2:2:end, :); % every two 
    else
        cd = pd(:, :, 1, 1:2, 1:end, :); % every one 
    end
    editers1 = zeros(size(cd, 1), size(cd, 2), size(cd, 5)); 
    editers2 = zeros(size(cd, 1), size(cd, 2), size(cd, 5)); 
    for dim5 = 1:size(cd, 5)
        raw_value1 = cd(:, :, 1, 1, dim5, :); % Raw matrix for dim5
        raw_value2 = cd(:, :, 1, 2, dim5, :); % Raw matrix for dim5
        SNR_raw = MSE_ABS(shiftyifft(raw_value1), shiftyifft(raw_value2)); 
    
        this_editer_img1 = devediter_full_autotuned_simplified(squeeze(raw_value1), 1, 1, 0, 1, 1, 3, 10);
        this_editer_img2 = devediter_full_autotuned_simplified(squeeze(raw_value2), 1, 1, 0, 1, 1, 3, 10);
        SNR_editer = MSE_ABS(this_editer_img1, this_editer_img2); 
        %[this_editer_img, ~, SNR_editer] = devediter_full_autotuned_simplified(squeeze(raw_value), 1, 0, 0, 7, 0, 3, 10);
    
        averaged_ksp1 = mean(cd(:, :, 1, 1, 1:dim5, :), 5); 
        averaged_ksp2 = mean(cd(:, :, 1, 2, 1:dim5, :), 5); 
        SNR_averaged = MSE_ABS(shiftyifft(averaged_ksp1), shiftyifft(averaged_ksp2)); 
    
        averaged_editer_img1 = devediter_full_autotuned_simplified(squeeze(averaged_ksp1), 1, 1, 0, 1, 1, 3, 10);
        averaged_editer_img2 = devediter_full_autotuned_simplified(squeeze(averaged_ksp2), 1, 1, 0, 1, 1, 3, 10);
        SNR_averaged_editer = MSE_ABS(averaged_editer_img1, averaged_editer_img2); 
        %[averaged_editer_img, ~, SNR_averaged_editer] = devediter_full_autotuned_simplified(squeeze(averaged_ksp), 1, 0, 0, 7, 0, 3, 10);
    
        editers1(:, :, dim5) = this_editer_img1; 
        editers2(:, :, dim5) = this_editer_img2; 
        individuals_avged1 = sum(editers1, 3) / dim5;
        individuals_avged2 = sum(editers2, 3) / dim5;
        SNR_individual = MSE_ABS(individuals_avged1, individuals_avged2); 
    
    
    
        raw_metrics = [raw_metrics; SNR_raw];
        raw_metrics_editer = [raw_metrics_editer; SNR_editer];
        averaged_metrics = [averaged_metrics; SNR_averaged];
        averaged_metrics_editer = [averaged_metrics_editer; SNR_averaged_editer];
        editer_individual = [editer_individual; SNR_individual];
    end 
end


plot(1:length(raw_metrics), raw_metrics, '-o', 'LineWidth', 2, 'DisplayName', 'Single Scan');
plot(1:length(raw_metrics_editer), raw_metrics_editer, '-o', 'LineWidth', 2, 'DisplayName', 'Single Scan (EDITER)');
plot(1:length(averaged_metrics), averaged_metrics, '-o', 'LineWidth', 2, 'DisplayName', 'N Averages');
plot(1:length(averaged_metrics_editer), averaged_metrics_editer, '-o', 'LineWidth', 2, 'DisplayName', 'N Averages (EDITER)');
plot(1:length(editer_individual), editer_individual, '-o', 'LineWidth', 2, 'DisplayName', 'EDITER Individually (averaged)');

% Legend, labels, title, and grid
legend;
xlabel('Index');
ylabel('Metric Value');
title('Comparison of EDITER combining with Averaging');
grid on; % Add grid for better visibility
hold off;
