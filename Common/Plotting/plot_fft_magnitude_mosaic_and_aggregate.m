function plot_fft_magnitude_mosaic_and_aggregate(kern_stack, num_coils)
    % Function to visualize FFT magnitudes of kernels in a mosaic format
    % and create a sum of FFT magnitudes across all coils for each kernel.
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

    % ----------- PLOT 2: Aggregate FFT Magnitudes for Each Kernel (Summed Across Coils) -----------
    figure('Name', 'Summed FFT Magnitude for All Kernels', 'NumberTitle', 'off');

    % Iterate through each kernel (detector) for the aggregate sum plot
    for i = 1:num_kernels
        % Extract the current kernel (transfer function for the current detector)
        current_kernel = kern_stack{i};

        % Check if the kernel is valid
        if ~isvector(current_kernel) || ~isnumeric(current_kernel)
            warning('kern_stack{%d} is not a numeric vector. Skipping.', i);
            continue;
        end

        % Initialize the summed FFT magnitude with the size of the first coil
        coil_kernel = current_kernel(1:num_coils:end);  % First coil sub-kernel
        fft_kernel = fftshift(fft(coil_kernel));  % Fourier transform of the first coil
        summed_fft_magnitude = zeros(size(fft_kernel));  % Initialize with zeros

        % Break the kernel into sub-kernels for each coil
        kernel_length = length(current_kernel);
        coil_indices = arrayfun(@(c) c:num_coils:kernel_length, 1:num_coils, 'UniformOutput', false);

        % For each coil, sum the FFT magnitudes
        for c = 1:num_coils
            % Extract the sub-kernel for this coil
            coil_kernel = current_kernel(coil_indices{c});

            % Compute the Fourier Transform of the sub-kernel and its magnitude
            fft_kernel = fftshift(fft(coil_kernel));  % Shift zero-frequency component to center
            fft_magnitude = abs(fft_kernel);  % Get the magnitude of the FFT

            % Sum the FFT magnitudes across coils (ensure same size)
            if length(fft_magnitude) == length(summed_fft_magnitude)
                summed_fft_magnitude = summed_fft_magnitude + fft_magnitude;
            else
                warning('Kernel %d, Coil %d has mismatched FFT size. Skipping.', i, c);
            end
        end

        % Create a subplot for the summed FFT magnitude
        subplot(num_kernels, 1, i);  % Create one subplot per kernel
        hold on;
        plot(summed_fft_magnitude, 'r');  % Plot the summed FFT magnitude in red
        xlabel('Frequency Index');
        ylabel('Summed Magnitude');
        title(sprintf('Kernel %d: Summed FFT Magnitude Across All Coils', i));
        grid on;
        hold off;
    end

    % Save the summed FFT magnitude plot
    saveas(gcf, fullfile(output_dir, 'Summed_FFT_Magnitude.png'));
    disp('Summed FFT magnitude plot has been generated and saved.');
end
