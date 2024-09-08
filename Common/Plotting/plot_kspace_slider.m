function plot_kspace_slider(combined_data, N, square_plot, scale_param)
    % Set default values for square_plot and scale_param if not provided
    if nargin < 3
        square_plot = false;
    end
    if nargin < 4
        scale_param = 0;
    end

    initialSlice = 1;

    % Adjust N if it doesn't work
    N = min(N, size(combined_data, 3) - 1); 

    % Determine the number of EMI detectors
    numEMIDetectors = size(combined_data, 4) - 1; 
    totalPlots = 1 + numEMIDetectors;

    % Create figure and axes for k-space visualization
    title = sprintf('K-Space Visualization - Scale Param: %g', scale_param);
    ax = figure('Name', title, 'NumberTitle', 'off');
    sliderKspace = uicontrol('Parent', ax, 'Style', 'slider', 'Units', 'normalized', ...
                             'Position', [0.1, 0, 0.8, 0.05], 'Value', initialSlice, ...
                             'min', 1, 'max', size(combined_data, 3) - N + 1, ...
                             'SliderStep', [1/(size(combined_data, 3) - N) 1/(size(combined_data, 3) - N)], ...
                             'Callback', @(src, event) updateKSpace(round(src.Value), N, combined_data, square_plot, scale_param));

    % Initial display
    updateKSpace(initialSlice, N, combined_data, square_plot, scale_param);
end

function updateKSpace(startSlice, numSlices, combined_data, square_plot, scale_param)
    primary_data = combined_data(:, :, :, 1); 
    numEMIDetectors = size(combined_data, 4) - 1; 
    totalPlots = 1 + numEMIDetectors;

    for jj = 0:numSlices-1
        idx = startSlice + jj;

        % Primary coil k-space data
        subplot(numSlices, totalPlots, 1 + jj * totalPlots);
        plot_with_scale(log1p(abs(primary_data(:, :, idx))), sprintf('Slice %d: Primary Coil K-Space', idx), square_plot, scale_param);

        % EMI coil k-space data
        for i = 1:numEMIDetectors
            emi_data_slice = combined_data(:, :, idx, 1 + i);
            subplot(numSlices, totalPlots, i + 1 + jj * totalPlots);
            plot_with_scale(log1p(abs(emi_data_slice)), sprintf('Slice %d: EMI Coil %d K-Space', idx, i), square_plot, scale_param);
        end
        
    end
end
