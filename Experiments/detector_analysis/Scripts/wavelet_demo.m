% MATLAB Code: Enhanced Wavelet Analysis of RF Detectors and White Noise

% Clear Workspace and Command Window
close all;
synthetic = false; 
DATASET = 4; 

% Generate Synthetic RF Detector Data (Replace with Actual Data)
% For demonstration, using sine waves with added noise
if synthetic
    NUM_DETECTORS = 4;                     % Number of RF Detectors
    SIGNAL_LENGTH = 1024;                  % Length of the Signals
    t = (0:SIGNAL_LENGTH-1)' / sampling_rate;
    mr_plane = zeros(SIGNAL_LENGTH, NUM_DETECTORS);
    for i = 1:NUM_DETECTORS
        frequency = 5 + i;  % Different frequency for each detector
        mr_plane(:, i) = sin(2 * pi * frequency * t) + 0.5 * randn(SIGNAL_LENGTH, 1);  % Example Signal
    end
else
    pd = read_in_common_dataset(DATASET);
    SLICE_2 = 20;  
    if size(pd, 5) > 1
        cd = squeeze(pd(:, SLICE_2, 1, 1, 2, :));
    else
        cd = squeeze(pd(:, SLICE_2, 1, 1, 1, :)); % when no calibration
    end
    mr_plane = abs(cd);
    NUM_DETECTORS = size(mr_plane, 2);
    SIGNAL_LENGTH = size(mr_plane, 1);
end 
sampling_rate = 1;                     % Adjust based on your data
titles = {'Primary', 'Detector 2', 'Detector 3', 'Detector 4'};
tlim = [0, SIGNAL_LENGTH / sampling_rate];  % Time Limits for Plots




% Generate White Noise
white_noise = randn(SIGNAL_LENGTH, 1);  % Zero-mean white Gaussian noise

% ===========================================
% Figure 1: Continuous Wavelet Transform (CWT)
% ===========================================
figure('Color', [1 1 1], 'Name', 'Continuous Wavelet Transform (CWT)');
NUM_PLOTS = NUM_DETECTORS% + 1;  % Detectors + White Noise
num_rows = 2;
num_cols = 4;
subplot_idx = 1;

for i = 1:NUM_DETECTORS
    subplot(num_rows, num_cols, subplot_idx);
    wt(abs(mr_plane(:, i)));
    title(titles{i});
    set(gca, 'xlim', tlim);
    subplot_idx = subplot_idx + 1;
end

% Plot White Noise
%subplot(num_rows, num_cols, subplot_idx);
%wt(abs(white_noise));
%title('White Noise');
%set(gca, 'xlim', tlim);

% Add Super Title
sgtitle('CWT (Ball)');

throw('gotcha')

% ===================================================
% Normalize Signals Using Custom Z-Score Function
% ===================================================
% Concatenate all signals for normalization
all_signals = [mr_plane, white_noise];

% Apply Custom Z-Score Normalization
all_signals_normalized = zscore_normalization(all_signals);

% Extract Normalized Signals
mr_plane_norm = all_signals_normalized(:, 1:NUM_DETECTORS);
white_noise_norm = all_signals_normalized(:, end);

% =============================================
% Figures 2-5: Pairwise XWT and WTC for Each Detector
% =============================================
for current_detector = 1:NUM_DETECTORS
    figure('Color', [1 1 1], 'Name', [titles{current_detector} ' - XWT and WTC']);
    sgtitle([titles{current_detector} ' - Cross Wavelet Transform and Wavelet Coherence']);
    
    % Define Comparisons: Other Detectors + White Noise
    comparisons = [1:NUM_DETECTORS, NUM_DETECTORS+1];  % Detectors 1-4 + White Noise
    comparisons(comparisons == current_detector) = [];  % Exclude self-transform here
    
    % Determine the number of comparisons
    num_comparisons = length(comparisons);
    
    % Initialize subplot index
    subplot_idx = 1;
    
    % Cross Wavelet Transform (XWT) - Row 1
    % Cross Wavelet Transform (XWT) - Row 1
for comp = 1:num_comparisons
    subplot(2, 4, comp);
    xwt(mr_plane_norm(:, current_detector), all_signals_normalized(:, comparisons(comp)));
    
    % Determine comparison title
    if comparisons(comp) <= NUM_DETECTORS
        comparison_title = titles{comparisons(comp)};
    else
        comparison_title = 'White Noise';
    end
    
    title(['XWT: ' titles{current_detector} ' vs ' comparison_title]);
    set(gca, 'xlim', tlim);
    colormap('jet');
    colorbar;
end

    
    % Wavelet Coherence (WTC) - Row 2
    for comp = 1:num_comparisons
        subplot(2, 4, comp + 4);  % Shift to second row
        wtc(mr_plane_norm(:, current_detector), all_signals_normalized(:, comparisons(comp)));
        
        % Determine comparison title using if-else
        if comparisons(comp) <= NUM_DETECTORS
            comparison_title = titles{comparisons(comp)};
        else
            comparison_title = 'White Noise';
        end
        
        title(['WTC: ' titles{current_detector} ' vs ' comparison_title]);
        set(gca, 'xlim', tlim);
        colormap('jet');
        colorbar;
    end
    
    % ===================================
    % Figure 6: Self-Transform of Detector
    % ===================================
    if false
        figure('Color', [1 1 1], 'Name', [titles{current_detector} ' - Self-Transform']);
        sgtitle([titles{current_detector} ' - Self Cross Wavelet Transform and Coherence']);
        
        % XWT with Itself
        subplot(2, 1, 1);
        xwt(mr_plane_norm(:, current_detector), mr_plane_norm(:, current_detector));
        title(['XWT: ' titles{current_detector} ' vs Itself']);
        set(gca, 'xlim', tlim);
        
        % WTC with Itself
        subplot(2, 1, 2);
        wtc(mr_plane_norm(:, current_detector), mr_plane_norm(:, current_detector));
        title(['WTC: ' titles{current_detector} ' vs Itself']);
        set(gca, 'xlim', tlim);
    end 
end