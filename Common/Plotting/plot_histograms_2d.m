function plot_histograms_2d(combined_data, data_name, img_space, logscale, standardize, min_binsize)
    % Set default values if not provided
    if nargin < 3
        img_space = false;
    end
    if nargin < 4
        logscale = true;
    end
    if nargin < 5
        standardize = false;
    end
    if nargin < 6
        min_binsize = 0;
    end

    % Determine the number of detectors
    num_detectors = size(combined_data, 3);

    % Calculate the grid size for subplots
    num_cols = ceil(sqrt(num_detectors));
    num_rows = ceil(num_detectors / num_cols);

    % Initialize parameters for standardization
    max_x = 0;
    max_y = 0;
    best_bin_edges = [];
    new_max_x = 0;

    % First pass to determine max_x, max_y, and bin_edges if standardizing
    for detector = 1:num_detectors
        if img_space
            % Perform 2D inverse Fourier transform to get image space data
            detectorslice = combined_data(:, :, detector);
            I2Dfid = ifftshift(ifft2(ifftshift(detectorslice)));
            flatData = abs(I2Dfid(:)); % Flatten the data
        else
            % Use k-space data
            flatData = abs(combined_data(:, :, detector));
            flatData = flatData(:); % Flatten the data
        end

        % Compute histogram to get bin edges and max_y
        [counts, edges] = histcounts(flatData, 'BinMethod', 'auto');
        current_max_x = max(flatData);
        if current_max_x > max_x
            max_x = current_max_x;
            best_bin_edges = edges;
        end
    end

    % Determine new_max_x based on min_binsize, now can also determine
    % max_y
    if min_binsize > 0
        for detector = 1:num_detectors
            if img_space
                % Perform 2D inverse Fourier transform to get image space data
                detectorslice = combined_data(:, :, detector);
                I2Dfid = ifftshift(ifft2(ifftshift(detectorslice)));
                flatData = abs(I2Dfid(:)); % Flatten the data
            else
                % Use k-space data
                flatData = abs(combined_data(:, :, detector));
                flatData = flatData(:); % Flatten the data
            end
            
            % Use best_bin_edges to ensure consistency
            [counts, edges] = histcounts(flatData, 'BinEdges', best_bin_edges);

            % max y compute 
            max_y = max(max_y, max(counts));

            % Find the maximum x value with counts exceeding min_binsize
            significant_bins = find(counts > min_binsize);
            if ~isempty(significant_bins)
                new_max_x = max(new_max_x, edges(significant_bins(end) + 1));
            end
        end
    else
        new_max_x = max_x;
    end


    % Create a new figure for the histograms
    figure('Name', sprintf('Histograms for %s', data_name), 'NumberTitle', 'on');

    % Loop through each detector and create a subplot for its histogram
    for detector = 1:num_detectors
        if img_space
            % Perform 2D inverse Fourier transform to get image space data
            detectorslice = combined_data(:, :, detector);
            I2Dfid = ifftshift(ifft2(ifftshift(detectorslice)));
            flatData = abs(I2Dfid(:)); % Flatten the data
        else
            % Use k-space data
            flatData = abs(combined_data(:, :, detector));
            flatData = flatData(:); % Flatten the data
        end
        
        % Create a subplot for the current detector
        subplot(num_rows, num_cols, detector);
        if standardize
            histogram(flatData, 'BinEdges', best_bin_edges);
        else
            histogram(flatData, 'BinMethod', 'auto');
        end
        
        if logscale
            set(gca, 'YScale', 'log'); % Set the Y-axis to logarithmic scale
        end
        
        % Add labels and title for each subplot
        xlabel('Magnitude');
        ylabel('Frequency');
        title(sprintf('Detector %d', detector));
        
        % Standardize x-axis and y-axis limits if needed
        if standardize
            xlim([0 new_max_x]);
            ylim([0 max_y]);
        else
            max_value = max(flatData);
            if max_value > 0
                xlim([0 max_value]);
            end
        end
        
        % Add text annotation for the max value
        if standardize
            max_value = max(flatData);
            yl = ylim;
            text(max_value, yl(2), sprintf('Max: %.2f', max_value), ...
                'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', ...
                'FontSize', 8, 'BackgroundColor', 'white');
        end
    end
    
    % Add an overall title for the entire figure
    prefix = ''; 
    if logscale
        prefix = 'LogScale-'; 
    end 
    if img_space
        suffix = sprintf('Histograms of Image Space Data for %s', data_name); 
    else
        suffix = sprintf('Histograms of K-Space Data for %s', data_name);
    end
    sgtitle(strcat(prefix, suffix)); 
end
