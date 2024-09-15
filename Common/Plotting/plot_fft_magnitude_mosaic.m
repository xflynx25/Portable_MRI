function plot_fft_magnitude_mosaic(kern_stack, num_coils)
    % Function to visualize FFT magnitudes of kernels in a mosaic format
    % 
    % Inputs:
    %   kern_stack - Cell array where each element is a kernel (transfer function).
    %   num_coils  - Number of coils to decompose each kernel.

    % Create a directory to save the plots
    output_dir = evalin('base', 'resultsDir');
    if ~exist(output_dir, 'dir')
        throw('output_dir dont exist, plz initpaths');
    end

    % Number of kernels (detectors)
    num_kernels = length(kern_stack);

    % Create a figure to hold the mosaic of FFT magnitudes
    figure('Name', 'FFT Magnitude Mosaic for All Kernels', 'NumberTitle', 'off');

    % Iterate through each kernel (detector)
    for i = 1:num_kernels
        % Extract the current kernel (transfer function for the current detector)
        current_kernel = kern_stack{i};

        % Check if the kernel is valid
        if ~isvector(current_kernel) || ~isnumeric(current_kernel)
            warning('kern_stack{%d} is not a numeric vector. Skipping.', i);
            continue;
        end

        % Break the kernel into sub-kernels for each coil
        kernel_length = length(current_kernel);
        coil_indices = arrayfun(@(c) c:num_coils:kernel_length, 1:num_coils, 'UniformOutput', false);

        % For each coil in the kernel, plot the FFT magnitude in a mosaic format
        for c = 1:num_coils
            % Extract the sub-kernel for this coil
            coil_kernel = current_kernel(coil_indices{c});

            % Compute the Fourier Transform of the sub-kernel and its magnitude
            fft_kernel = fftshift(fft(coil_kernel));  % Shift zero-frequency component to center
            fft_magnitude = abs(fft_kernel);  % Get the magnitude of the FFT

            % Create a subplot in the mosaic format
            subplot(num_kernels, num_coils, (i-1)*num_coils + c);  % Arrange subplots in a grid
            hold on;
            plot(fft_magnitude, 'k');  % Plot the FFT magnitude in black
            %xlabel('Frequency Index');
            %ylabel('Magnitude');
            title(sprintf('Kernel %d, Coil %d', i, c));  % Title for each subplot
            grid on;
            hold off;
        end
    end

    sgtitle('FFT Magnitude Mosaic for All Kernels', 'FontSize', 16, 'FontWeight', 'bold');

    % Save the mosaic plot for FFT magnitudes
    saveas(gcf, fullfile(output_dir, 'FFT_Magnitude_Mosaic.png'));

    disp('FFT magnitude mosaic plot has been generated and saved.');
end
