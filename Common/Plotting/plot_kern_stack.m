function plot_kern_stack(kern_stack, num_coils)
    % Function to visualize kernels and their Fourier transforms from kern_stack.
    % 
    % Inputs:
    %   kern_stack - Cell array where each element is a kernel (transfer function).
    %   num_coils  - Number of coils to decompose each kernel.
    
    % Create a directory to save the plots
    output_dir = 'kern_stack_plots';
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    % Number of kernels (detectors)
    num_kernels = length(kern_stack);

    % Iterate through each kernel (detector)
    for i = 1:num_kernels
        kernel_name = 18+i; %i; % changed this when plotting tfs from the middle 
        % Extract the current kernel (transfer function for the current detector)
        current_kernel = kern_stack{i};

        % Check if the kernel is valid
        if ~isvector(current_kernel) || ~isnumeric(current_kernel)
            warning('kern_stack{%d} is not a numeric vector. Skipping.', kernel_name);
            continue;
        end

        % Determine the length of the kernel and check if it's divisible by num_coils
        kernel_length = length(current_kernel);
        if mod(kernel_length, num_coils) ~= 0
            warning('Kernel %d length is not divisible by num_coils. Skipping.', kernel_name);
            continue;
        end

        % Preallocate variables for summing the transfer functions and FFTs
        sum_real = 0;
        sum_imag = 0;
        sum_magnitude = 0;
        sum_fft_magnitude = 0;

        % Break the kernel into sub-kernels for each coil
        coil_indices = arrayfun(@(c) c:num_coils:kernel_length, 1:num_coils, 'UniformOutput', false);

        % Create a figure for this kernel, with num_coils subplots for Transfer Function and FFT
        figure('Name', sprintf('Kernel %d Visualization (num_coils = %d)', kernel_name, num_coils), 'NumberTitle', 'off');

        for c = 1:num_coils
            % Extract the sub-kernel for this coil
            coil_kernel = current_kernel(coil_indices{c});

            % Compute real, imaginary, and magnitude parts
            real_part = real(coil_kernel);
            imag_part = imag(coil_kernel);
            magnitude = abs(coil_kernel);

            % Fourier Transform of the sub-kernel
            fft_kernel = fftshift(fft(coil_kernel));  % Shift zero-frequency component to center

            % Subplot for Real, Imaginary, and Magnitude (Transfer Function)
            subplot(num_coils, 2, 2*c-1);  % Allocate subplot space, 2 columns per coil
            hold on;
            plot(real_part, 'b', 'DisplayName', 'Real');  % Plot real part
            plot(imag_part, 'r', 'DisplayName', 'Imaginary');  % Plot imaginary part
            plot(magnitude, 'g', 'DisplayName', 'Magnitude');  % Plot magnitude
            xlabel('Kernel Index');
            ylabel('Value');
            title(sprintf('Kernel %d, Coil %d: Transfer Function', kernel_name, c));
            legend('show');
            grid on;
            hold off;

            % Subplot for Fourier Transform of the sub-kernel
            subplot(num_coils, 2, 2*c);  % Allocate next column for FFT
            hold on;
            plot(abs(fft_kernel), 'k', 'DisplayName', 'Magnitude of FFT');
            xlabel('Frequency Index');
            ylabel('FFT Magnitude');
            title(sprintf('Kernel %d, Coil %d: Fourier Transform (fftshift applied)', kernel_name, c));  % Emphasize fftshift
            legend('show');
            grid on;
            hold off;

            % Sum up the values across coils for this kernel
            sum_real = sum_real + real_part;
            sum_imag = sum_imag + imag_part;
            sum_magnitude = sum_magnitude + magnitude;
            sum_fft_magnitude = sum_fft_magnitude + abs(fft_kernel);
        end

        % Save the figure for the current kernel
        saveas(gcf, fullfile(output_dir, sprintf('Kernel_%d.png', kernel_name)));
        % Optionally, close the figure to save memory
        %close(gcf);

        % --- Summed plots for each kernel (Transfer Function and FFT) ---
        figure('Name', sprintf('Summed Transfer Function and Fourier Transform for Kernel %d', kernel_name), 'NumberTitle', 'off');

        % Subplot for the summed Transfer Function (Real, Imaginary, Magnitude)
        subplot(1, 2, 1);  % Left side for summed transfer function
        hold on;
        plot(sum_real, 'b', 'DisplayName', 'Summed Real');
        plot(sum_imag, 'r', 'DisplayName', 'Summed Imaginary');
        plot(sum_magnitude, 'g', 'DisplayName', 'Summed Magnitude');
        xlabel('Kernel Index');
        ylabel('Summed Value');
        title(sprintf('Kernel %d: Summed Transfer Function (Real, Imaginary, Magnitude)', kernel_name));
        legend('show');
        grid on;
        hold off;

        % Subplot for the summed Fourier Transform Magnitude
        subplot(1, 2, 2);  % Right side for summed FFT magnitude
        hold on;
        plot(sum_fft_magnitude, 'k', 'DisplayName', 'Summed FFT Magnitude');
        xlabel('Frequency Index');
        ylabel('Summed FFT Magnitude');
        title(sprintf('Kernel %d: Summed Fourier Transform Magnitude (fftshift applied)', kernel_name));  % Emphasize fftshift
        legend('show');
        grid on;
        hold off;

        % Save the summed plot for this kernel
        saveas(gcf, fullfile(output_dir, sprintf('Summed_Kernel_%d_Transfer_FFT.png', kernel_name)));
    end

    disp('All kernel plots and Fourier transforms for each coil have been generated.');
end
