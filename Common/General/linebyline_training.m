% just fitting division in fourier , 2 detectors 
function [kern_stack, win_stack] = linebyline_training(calibration, original_options)
    % LINEBYLINE_TRAINING performs FFT on each line of calibration data and computes the w-space kernel
    W = original_options.W;
    [num_freq, num_lines, num_coils] = size(calibration);
    kern_stack = cell(num_lines, 1);  % Cell array to store the kernel for each line
    win_stack = cell(num_lines, 1);   % Cell array to store the window stack for each line


    for line = 1:num_lines
        line_data = squeeze(calibration(:, line, :));  % size: [num_freq, num_coils]
        primary = line_data(:, 1);
        detector = line_data(:, 2);
        fft_primary = shiftyfft(primary); 
        fft_detector = shiftyfft(detector); 

        kern_stack{line} = fft_detector ./ fft_primary;
        win_stack{line} = line:line; 
    end

end