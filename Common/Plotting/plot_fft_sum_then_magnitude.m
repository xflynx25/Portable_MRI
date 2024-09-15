function plot_fft_sum_then_magnitude(kern_stack, num_coils)
    % Function to visualize the magnitude of the sums of real and imaginary parts of FFTs
    % from all coils for each kernel.
    % 
    % Inputs:
    %   kern_stack - Cell array where each element is a kernel (transfer function).
    %   num_coils  - Number of coils to decompose each kernel.

    % Set maximum number of plots per row
    max_plots_per_row = 5;

    % Create a directory to save the plots
    output_dir = evalin('base', 'resultsDir');
    if ~exist(output_dir, 'dir')
        error('output_dir does not exist, please initialize paths.');
    end

    % Number of kernels (detectors)
    num_kernels = length(kern_stack);

    % Calculate number of rows needed (ceiling of num_kernels / max_plots_per_row)
    num_rows = ceil(num_kernels / max_plots_per_row);

    % ----------- PLOT: Magnitude of the Sum of FFT Real and Imaginary Parts Across Coils -----------
    figure('Name', 'Magnitude of Sum of Real and Imaginary Parts for All Kernels', 'NumberTitle', 'off');

    % Iterate through each kernel (detector) for the new summation method
    for i = 1:num_kernels
        % Extract the current kernel (transfer function for the current detector)
        current_kernel = kern_stack{i};

        % Check if the kernel is valid
        if ~isvector(current_kernel) || ~isnumeric(current_kernel)
            warning('kern_stack{%d} is not a numeric vector. Skipping.', i);
            continue;
        end

        % Initialize variables to sum the real and imaginary parts of all coils
        sum_real_part = 0;
        sum_imag_part = 0;

        % Break the kernel into sub-kernels for each coil
        kernel_length = length(current_kernel);
        coil_indices = arrayfun(@(c) c:num_coils:kernel_length, 1:num_coils, 'UniformOutput', false);

        % For each coil, sum the real and imaginary parts
        for c = 1:num_coils
            % Extract the sub-kernel for this coil
            coil_kernel = current_kernel(coil_indices{c});

            % Compute the Fourier Transform of the sub-kernel
            fft_kernel = fftshift(fft(coil_kernel));  % Shift zero-frequency component to center

            % Add real and imaginary parts separately
            sum_real_part = sum_real_part + real(fft_kernel);
            sum_imag_part = sum_imag_part + imag(fft_kernel);
        end

        % Compute the magnitude of the summed real and imaginary parts
        magnitude_of_sum = abs(sum_real_part + 1i * sum_imag_part);

        % Calculate subplot position in a grid with num_rows and max_plots_per_row
        subplot(num_rows, max_plots_per_row, i);  % Create a balanced grid of subplots
        hold on;
        plot(magnitude_of_sum, 'b');  % Plot the magnitude of the sum in blue
        %xlabel('Frequency Index');
        %ylabel('Magnitude of Sum');
        %title(sprintf('Kernel %d: Magnitude of Summed Real+Imaginary Parts', i));
        grid on;
        hold off;
    end

    sgtitle('|Sum of Coils| - Noisy Brain', 'FontSize', 16, 'FontWeight', 'bold');


    % Save the summed FFT magnitude plot
    saveas(gcf, fullfile(output_dir, 'Magnitude_of_Summed_Real_Imaginary.png'));
    disp('Magnitude of summed real and imaginary part plot has been generated and saved.');
end
