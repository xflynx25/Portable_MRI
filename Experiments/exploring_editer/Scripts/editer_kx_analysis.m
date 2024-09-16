% This script will try and elucidate the mysteries of editer (round 2)
% Phase 1: what is being fit? 
% Phase 2: how do they work together (correlation analysis)
% Phase 3: how does it vary with parameters


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
ksz_col_initial_values = [0, 1, 3];
ksz_col_final_values = [0, 1, 3];
ksz_col_initial_values = [0, 3];
ksz_col_final_values = [0, 3];
num_values_i = length(ksz_col_initial_values);
num_values_f = length(ksz_col_final_values);

% Initialize a matrix to store SNR results
SNR_matrix = zeros(num_values_i, num_values_f);

% Other parameters
W = 1; % number of PE per initial window
ksz_lin_initial = 0; 
correlation_eps = 3e-1; 
ksz_lin_final = 0; 
MAX_KERNSTACK_TO_PLOT = 15; 
num_emi_coils = num_coils - 1;
mingroupingsize = 0; 

% Save the current directory
cd_copy = cd; 

% allow to select the region by setting this to false
SNR = calculate_snr_saving2d(primary_img, true);

% Loop through all combinations of ksz_col_initial and ksz_col_final
for i = 1:num_values_i
    for j = 1:num_values_f
        ksz_col_initial = ksz_col_initial_values(i);
        ksz_col_final = ksz_col_final_values(j);

        %[corrected_img_dev, corrected_ksp_dev] = devediter_full_autotuned(cd_copy, W, ksz_col_initial, ksz_lin_initial, ...
    %ksz_col_final, ksz_lin_final, 15, 100, 3);

        [corrected_img_dev, corrected_ksp_dev] = devediter_full_autotuned_simplified(cd_copy, W, ksz_col_initial, ksz_lin_initial, ...
    ksz_col_final, ksz_lin_final, mingroupingsize);


        % Calculate SNR
        SNR = calculate_snr_saving2d(corrected_img_dev, true);
        %throw('j')
        
        % Store the SNR in the matrix
        SNR_matrix(i, j) = SNR;
        
        % Optionally display progress
        fprintf('SNR for ksz_col_initial = %d and ksz_col_final = %d: %.2f\n', ...
                ksz_col_initial, ksz_col_final, SNR);
        % plot this guy
        plot_editer_advanced_equalcolors(primary_img, corrected_img_dev, IMAGE_SCALE);
    end
end
% -------------------------------------------
% 4. Visualization with imagesc (Categorical Axes)
% -------------------------------------------

% Create a figure for the heatmap
figure;
hold on; % Hold on to add more plot elements if needed

% Use imagesc to visualize the SNR matrix
% Here, we use indices (1:num_values) for positioning
imagesc(SNR_matrix);

% Add colorbar and set its label
c = colorbar; % Returns a handle to the colorbar
c.Label.String = 'SNR'; % Set the colorbar title

% Set axis labels and title
xlabel('Final ksz\_col', 'FontSize', 12);
ylabel('Initial ksz\_col', 'FontSize', 12);
title('SNR Results for Different ksz\_col Initial and Final Values', 'FontSize', 14, 'FontWeight', 'bold');

% Set axis ticks to correspond to the indices
set(gca, 'XTick', 1:num_values_i, 'YTick', 1:num_values_f);

% Assign the category values as tick labels
set(gca, 'XTickLabel', arrayfun(@num2str, ksz_col_initial_values, 'UniformOutput', false));
set(gca, 'YTickLabel', arrayfun(@num2str, ksz_col_final_values, 'UniformOutput', false));

% Adjust colormap for better visualization
colormap(jet); % You can choose other colormaps like 'hot', 'parula', etc.

% Ensure the aspect ratio is equal for better interpretation
axis equal tight;

% Optionally, add grid lines for clarity
grid on;

% Improve grid line appearance
ax = gca;
ax.GridColor = [0 0 0]; % Black grid lines
ax.GridAlpha = 0.5;      % Semi-transparent grid lines

% Add text labels for each cell showing the SNR value
% (Optional: Useful for small matrices)
for i = 1:num_values_i
    for j = 1:num_values_f
        % Position text in the center of each cell
        % Determine text color based on background for readability
        if SNR_matrix(i,j) > (max(SNR_matrix(:)) + min(SNR_matrix(:)))/2
            textColor = 'w'; % White text for darker backgrounds
        else
            textColor = 'k'; % Black text for lighter backgrounds
        end
        
        text(j, i, sprintf('%.2f', SNR_matrix(i,j)), ...
             'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'middle', ...
             'Color', textColor, ...
             'FontWeight', 'bold');
    end
end

% Release the hold on the current figure
hold off;
