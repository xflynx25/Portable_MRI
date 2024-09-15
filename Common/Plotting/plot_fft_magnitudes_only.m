function plot_fft_magnitudes_only(kern_stack, num_coils)
    % Function to visualize ONLY the FFT magnitudes of kernels from kern_stack.
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

    % Iterate through each kernel (detector)
    for i = 1:num_kernels
        % Extract the current kernel (transfer function for the current detector)
        current_kernel = kern_stack{i};

        % Check if the kernel is valid
        if ~isvector(current_kernel) || ~isnumeric(current_kernel)
            warning('kern_stack{%d} is not a numeric vector. Skipping.', i);
            continue;
        end

        % Preallocate the sum of FFT magnitudes
        sum_fft_magnitude = 0;

        % Break the kernel into sub-kernels for each coil
        kernel_length = length(current_kernel);
        coil_indices = arrayfun(@(c) c:num_coils:kernel_length, 1:num_coils, 'UniformOutput', false);

        % Create a figure for this kernel to plot FFT Magnitudes
        figure('Name', sprintf('Kernel %d: FFT Magnitudes', i), 'NumberTitle', 'off');

        for c = 1:num_coils
            % Extract the sub-kernel for this coil
            coil_kernel = current_kernel(coil_indices{c});

            % Compute Fourier Transform and its magnitude
            fft_kernel = fftshift(fft(coil_kernel));  % Shift zero-frequency component to center
            fft_magnitude = abs(fft_kernel);  % Get the magnitude of the FFT

            % Subplot for Fourier Transform Magnitude
            subplot(num_coils, 1, c);  % Allocate subplot space for each coil
            hold on;
            plot(fft_magnitude, 'k', 'DisplayName', 'FFT Magnitude');
            xlabel('Frequency Index');
            ylabel('Magnitude');
            title(sprintf('Kernel %d, Coil %d: FFT Magnitude', i, c));
            grid on;
            hold off;

            % Sum up the FFT magnitudes across coils for this kernel
            sum_fft_magnitude = sum_fft_magnitude + fft_magnitude;
        end

        % Save the individual FFT magnitude plot for this kernel
        saveas(gcf, fullfile(output_dir, sprintf('Kernel_%d_FFT_Magnitudes.png', i)));
        close(gcf);

        % --- Plot summed FFT magnitude across coils ---
        figure('Name', sprintf('Summed FFT Magnitude for Kernel %d', i), 'NumberTitle', 'off');
        hold on;
        plot(sum_fft_magnitude, 'r', 'DisplayName', 'Summed FFT Magnitude');
        xlabel('Frequency Index');
        ylabel('Summed Magnitude');
        title(sprintf('Kernel %d: Summed FFT Magnitude Across All Coils', i));
        grid on;
        hold off;

        % Save the summed FFT magnitude plot for this kernel
        saveas(gcf, fullfile(output_dir, sprintf('Kernel_%d_Summed_FFT_Magnitude.png', i)));
        close(gcf);
    end

    disp('All FFT magnitude plots and summed FFT plots for each kernel have been generated.');
end
