function plot_editer_advanced_equalcolors(uncorrected, corrected, scale_param, varargin)
    % plot_editer_advanced
    % Plots uncorrected, corrected, and difference images on the same scale.
    %
    % Parameters:
    %   uncorrected - Matrix representing the uncorrected data.
    %   corrected   - Matrix representing the corrected data.
    %   scale_param - Parameter to determine scaling (0: absolute, <1: clim, >=1: logarithmic).
    %   varargin    - Optional arguments: x_range, y_range, daspect_ratio.

    % Determine the available range
    [x_size, y_size] = size(uncorrected);
    daspect_ratio = x_size / y_size;
    
    % Default ranges
    x_range = 1:x_size;
    y_range = 1:y_size;
    
    % Update optional arguments if provided
    if ~isempty(varargin)
        if length(varargin) >= 2
            x_range = varargin{1};
            y_range = varargin{2};
            if length(varargin) >= 3
                daspect_ratio = varargin{3};
            end
        end
    end

    % Prepare data for plotting
    uncorrected_data = abs(uncorrected(x_range, y_range));
    corrected_data = abs(corrected(x_range, y_range));
    diff_data = abs(uncorrected_data - corrected_data);

    % Determine global maximum across all datasets
    global_max = max([uncorrected_data(:); corrected_data(:); diff_data(:)]);

    % Create a new figure with a tiled layout
    figure;
    t = tiledlayout(1, 3, 'TileSpacing', 'Compact', 'Padding', 'Compact');
    % Uncomment the next line if you want a super title
    % sgtitle('Comparison of Uncorrected, Corrected, and Difference Images');

    global_max = 0; 

    % Plot Uncorrected Image
    nexttile;
    maxval = plot_with_scale(uncorrected_data, 'Primary Uncorrected', true, scale_param);
    global_max = max(global_max, maxval)
    clim([0, global_max]);

    % Plot Corrected Image
    nexttile;
    plot_with_scale(corrected_data, 'Corrected with EDITER', true, scale_param);
    global_max = max(global_max, maxval)
    clim([0, global_max]);

    % Plot Difference Image
    nexttile;
    plot_with_scale(diff_data, 'Difference Image', true, scale_param);
    global_max = max(global_max, maxval)
    clim([0, global_max]);

    % Calculate and display RMS errors
    erms = rms(abs(uncorrected(:) - corrected(:)));
    fprintf('RMS Error (with no EMI Correction): %.4f\n', erms);
    normalized_erms = rms(abs(uncorrected(:) - corrected(:)) / rms(abs(corrected(:))));
    fprintf('Normalized RMS Error (with no EMI Correction): %.4f\n', normalized_erms);
end
