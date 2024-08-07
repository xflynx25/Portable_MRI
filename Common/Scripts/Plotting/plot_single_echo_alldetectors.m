function plot_single_echo_alldetectors(combined_data, line, slice)
    % Determine the number of detectors
    num_detectors = size(combined_data, 4);
    
    % Calculate the grid size for subplots
    num_cols = ceil(sqrt(num_detectors));
    num_rows = ceil(num_detectors / num_cols);

    % Create a new figure for the combined subplots
    figure('Name', sprintf('All Echoes for Line (%d), Slice (%d)', line, slice), 'NumberTitle', 'on');

    % Loop through each detector and create a subplot for its echo
    for detector = 1:num_detectors
        singleecho = squeeze(combined_data(:, line, slice, detector));
        echo_signal = abs(ifftshift(ifft(ifftshift(singleecho))));
        
        % Create a subplot for the current detector
        subplot(num_rows, num_cols, detector);
        plot(echo_signal);
        
        % Add labels and title for each subplot
        xlabel('Sample Index');
        ylabel('Magnitude');
        title(sprintf('Detector %d', detector));
        grid on; % Add a grid for better readability
    end
    
    % Add an overall title for the entire figure
    sgtitle(sprintf('Echoes for Line (%d), Slice (%d)', line, slice));
end