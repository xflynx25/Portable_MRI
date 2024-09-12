% just fitting division in fourier , 2 detectors 
function [kern_stack, win_stack] = linebyline_training(calibration, original_options)
    % LINEBYLINE_TRAINING performs FFT on each line of calibration data and computes the w-space kernel
    W = original_options.W;
    [num_freq, num_lines, num_coils] = size(calibration);
    kern_stack = cell(num_lines / W, 1);  % Cell array to store the kernel for each line
    win_stack = cell(num_lines / W, 1);   % Cell array to store the window stack for each line


    % Loop over lines in chunks of W
    cwin = 1;
    for line = 1:W:num_lines
        % Define the phase encode range (pe_rng) for this window
        pe_rng = line:min(line + W - 1, num_lines);  % Ensure we don't go past the last line
        win_stack{cwin} = pe_rng;  % Store the range in the window stack

        % Combine lines within this window
        fft_primary_sum = zeros(num_freq, 1);  % Initialize to accumulate the primary coil data
        fft_detector_sum = zeros(num_freq, 1);  % Initialize to accumulate the detector coil data
        
        % Sum the FFTs across the lines in this window
        for subline = pe_rng
            line_data = squeeze(calibration(:, subline, :));  % size: [num_freq, num_coils]
            primary = line_data(:, 1);   % Data from the primary coil (1st column)
            detector = line_data(:, 2);  % Data from the detector coil (2nd column)

            % Fourier transform for both coils
            fft_primary = shiftyfft(primary); 
            fft_detector = shiftyfft(detector);

            % Sum the Fourier-transformed data for this window
            fft_primary_sum = fft_primary_sum + fft_primary;
            fft_detector_sum = fft_detector_sum + fft_detector;
        end
        
        % Find the best-fit kernel by minimizing the MSE between primary and detector in the FFT domain
        % Solve for 'K' such that || K * fft_primary_sum - fft_detector_sum ||^2 is minimized
        K = fft_detector_sum ./ fft_primary_sum;  % Pointwise division gives the best-fit multiplier
        
        % Store the kernel for this window in kern_stack
        kern_stack{cwin} = K;  % This kernel will be applied to all lines in this window

        % Move to the next window
        cwin = cwin + 1;
    end
    kern_stack{1}
end