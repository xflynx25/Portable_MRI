
function [corrected_img, corrected_ksp] = linebyline_inference(mr_acquisition, kern_stack, win_stack)
    % take the winstack, and for each set of lines (for starters it will
    % just be single values
    % for each set, we will utilize the corresponding kernel, and apply it
    % to the line in the mr. We fft, apply kernel, ifft, 

    % that gives us our corrected_ksp, and at the end we of course do
    % another ifft.

    mr_primary = mr_acquisition(:, :, 1);
    mr_detectors = mr_acquisition(:, :, 2:end);

    [num_freq, num_lines, num_coils] = size(mr_detectors); 
    residual_ksp = zeros(num_freq, num_lines, num_coils); 
        
    % Loop through each window in win_stack
    for cwin = 1:length(win_stack)
        kern = kern_stack{cwin};
        pe_rng = win_stack{cwin};  
        for line = 1:length(pe_rng)
            current_line = pe_rng(line); 

            for coil = 1:num_coils  % Start from 2 (as coil 1 is the reference)
                line_data = squeeze(mr_detectors(:, current_line, coil));  % size: [num_freq, num_coils]
                wspace = shiftyfft(line_data) .* kern;
                residual_ksp(:, current_line, coil) = shiftyifft(wspace); 
            end
        end
    end
    
    % Reconstruct the final corrected image using sum-of-squares across coils
    %residual_ksp = sqrt(sum(abs(residual_ksp).^2, 3));  % Combine coils using sum-of-squares
    corrected_ksp = mr_primary - residual_ksp(:, :, 1); 
    corrected_img = shiftyifft(corrected_ksp); 
end