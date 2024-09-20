
% USER INPUT
scan_selector = 4; 
IMAGE_SCALE = 2; 
KSPACE_SCALE = 0; 
METRIC = 'SNR_base'; 
%METRIC = 'SNR_editer'; 
SNRSQUARES_ALREADY_SET = true; 
calibration_trial = true; 


% LOADING, PREPARATION
close all; %plots
pd = read_in_common_dataset(scan_selector); 


% FORMATTING
disp('references')
if size(pd, 5) > 1 & calibration_trial
    cd = pd(:, :, 1, :, 2:2:end, :); % every two 
else
    cd = pd(:, :, 1, :, 1:end, :); % every one 
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
raw_metrics_dim41 = []; % Raw metrics for dim4
repeat_metrics1 = [];   % Repeat metrics for dim4
consecutive_metrics1 = []; % Consecutive metrics for dim5
raw_metrics_dim51 = []; % Raw metrics for dim5

raw_metrics_dim42 = []; % Raw metrics for dim4
repeat_metrics2 = [];   % Repeat metrics for dim4
consecutive_metrics2 = []; % Consecutive metrics for dim5
raw_metrics_dim52 = []; % Raw metrics for dim5

% first get raw and repeats in dimension 4
dim5 = 1; 
for dim4 = 1:size(cd, 4)
    raw_value = cd(:, :, 1, dim4, dim5, :); % Raw matrix
    
    % Raw plot: calculate metric for raw_value (for dim4)
    raw_metric = metric(raw_value, METRIC);
    raw_metrics_dim41 = [raw_metrics_dim41; raw_metric];

    % Repeat: running average along dim4
    repeat_value = sum(cd(:, :, 1, 1:dim4, dim5, :), 4);
    repeat_metric = metric(repeat_value, METRIC);
    repeat_metrics1 = [repeat_metrics1; repeat_metric];
end
dim5 = 2; 
for dim4 = 1:size(cd, 4)
    raw_value = cd(:, :, 1, dim4, dim5, :); % Raw matrix
    
    % Raw plot: calculate metric for raw_value (for dim4)
    raw_metric = metric(raw_value, METRIC);
    raw_metrics_dim42 = [raw_metrics_dim42; raw_metric];

    % Repeat: running average along dim4
    repeat_value = sum(cd(:, :, 1, 1:dim4, dim5, :), 4);
    repeat_metric = metric(repeat_value, METRIC);
    repeat_metrics2 = [repeat_metrics2; repeat_metric];
end

% Now get raw and consecutive metrics in dimension 5
dim4 = 1; % Fixed dim4 for the second loop
for dim5 = 1:size(cd, 5)
    % Raw plot: calculate metric for raw_value (for dim5)
    raw_value = cd(:, :, 1, dim4, dim5, :); % Raw matrix for dim5
    raw_metric_dim5 = metric(raw_value, METRIC);
    raw_metrics_dim51 = [raw_metrics_dim51; raw_metric_dim5];
    
    % Consecutive: running average along dim5
    consecutive_value = sum(cd(:, :, 1, dim4, 1:dim5, :), 5);
    consecutive_metric = metric(consecutive_value, METRIC);
    consecutive_metrics1 = [consecutive_metrics1; consecutive_metric];
end
dim4 = 2; % Fixed dim4 for the second loop
for dim5 = 1:size(cd, 5)
    % Raw plot: calculate metric for raw_value (for dim5)
    raw_value = cd(:, :, 1, dim4, dim5, :); % Raw matrix for dim5
    raw_metric_dim5 = metric(raw_value, METRIC);
    raw_metrics_dim52 = [raw_metrics_dim52; raw_metric_dim5];
    
    % Consecutive: running average along dim5
    consecutive_value = sum(cd(:, :, 1, dim4, 1:dim5, :), 5);
    consecutive_metric = metric(consecutive_value, METRIC);
    consecutive_metrics2 = [consecutive_metrics2; consecutive_metric];
end

% Plotting the results with thicker lines and different colors
figure;
hold on;

% Plot for raw metrics (dimension 4)
%plot(1:length(raw_metrics_dim41), raw_metrics_dim41, '-o', 'LineWidth', 2, 'DisplayName', 'Raw (dim5 = 1)');
%plot(1:length(raw_metrics_dim42), raw_metrics_dim42, '-o', 'LineWidth', 2, 'DisplayName', 'Raw (dim5 = 2)');
plot(1:length(raw_metrics_dim51), raw_metrics_dim51, '-o', 'LineWidth', 2, 'DisplayName', 'Raw (Repeat 1)');
plot(1:length(raw_metrics_dim52), raw_metrics_dim52, '-o', 'LineWidth', 2, 'DisplayName', 'Raw (Repeat 2)');

% Plot for repeat metrics (dimension 4)
plot(1:length(repeat_metrics1), repeat_metrics1, '-x', 'LineWidth', 2, 'DisplayName', 'Repeat Score (cons=1)');
plot(1:length(repeat_metrics2), repeat_metrics2, '-x', 'LineWidth', 2, 'DisplayName', 'Repeat Score (cons=2)');
plot(1:length(consecutive_metrics1), consecutive_metrics1, '-x', 'LineWidth', 2, 'DisplayName', 'Consecutive Score (repeat=1)');
plot(1:length(consecutive_metrics2), consecutive_metrics2, '-x', 'LineWidth', 2, 'DisplayName', 'Consecutive Score (repeat=2)');



%plot(1:length(repeat_metrics2), repeat_metrics2, '-x', 'LineWidth', 2, 'Color', 'b', 'DisplayName', 'Repeat (Dim4)');
%%plot(1:length(repeat_metrics), repeat_metrics, '-x', 'LineWidth', 2, 'Color', 'b', 'DisplayName', 'Repeat (Dim4)');
%plot(1:length(repeat_metrics), repeat_metrics, '-x', 'LineWidth', 2, 'Color', 'b', 'DisplayName', 'Repeat (Dim4)');
%plot(1:length(consecutive_metrics), consecutive_metrics, '-s', 'LineWidth', 2, 'Color', 'g', 'DisplayName', 'Consecutive (Dim5)');

% Legend, labels, title, and grid
legend;
xlabel('Index');
ylabel('SNR');
title('SNR Comparison: Repeat vs Consecutive Averaging');
grid on; % Add grid for better visibility
hold off;
