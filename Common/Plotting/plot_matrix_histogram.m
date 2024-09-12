function plot_matrix_histogram(matrix, num_bins, logscale)
    % Function to plot the histogram of an n-dimensional matrix.
    % matrix: n-dimensional matrix to be flattened
    % num_bins: number of bins for the histogram (optional)

    if nargin < 2
        num_bins = 50;  % Default number of bins
    end
    if nargin < 3
        logscale = false; 
    end

    % Flatten the matrix to 1D
    flattened_data = matrix(:);

    % Plot the histogram (this will plot in the current subplot)
    h = histogram(flattened_data, num_bins);
    title('Histogram of Matrix Values');
    xlabel('Value');
    ylabel('Frequency');
        
    if logscale
        set(gca, 'YScale', 'log');
        ylabel('Frequency (logscale)');
        ylim([10^-.1, max(h.Values) * 1.1]);  % Adjust the lower limit to 10^-1
    end
    
    % Display some basic statistics on the plot
    mean_val = mean(flattened_data);
    std_val = std(flattened_data);
    % Adding annotation in the current axes
    %annotation('textbox', [0.6, 0.75, 0.3, 0.1], 'String', sprintf('Mean: %.2f, Std: %.2f', mean_val, std_val), 'FitBoxToText', 'on', 'EdgeColor', 'none');
end
