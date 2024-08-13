function [kern_stack] = compute_kernels(combined_data, win_stack, ksz_col, ksz_lin)

    Nc = size(combined_data, 3) - 1;  % Number of noise detectors
    kern_stack = cell(length(win_stack), 1);
    padded_combined_data = padarray(combined_data, [ksz_col ksz_lin 0]);

    for cwin = 1:length(win_stack)
        noise_mat = [];
        pe_rng = win_stack{cwin}; % list (or single) of lines that are grouped
        min_pe = min(pe_rng);
        max_pe = max(pe_rng);

        % Pad arrays for each detector
        paddedData = cell(Nc, 1);
        for d = 1:Nc
            paddedData{d} = padded_combined_data(:, min_pe:max_pe+2*ksz_lin, d+1); 
        end

        % Construct noise matrix
        for col_shift = -ksz_col:ksz_col
            for lin_shift = -ksz_lin:ksz_lin
                for d = 1:Nc
                    dftmp = circshift(paddedData{d}(:,:), [col_shift, lin_shift]);
                    noise_mat = cat(3, noise_mat, dftmp(ksz_col + 1:end - ksz_col, ksz_lin + 1:end - ksz_lin));
                end
            end
        end

        
        % kernels
        gmat = reshape(noise_mat, size(noise_mat, 1) * size(noise_mat, 2), size(noise_mat, 3));
        init_mat_sub = combined_data(:, pe_rng, 1);

        kern = pinv(gmat) * init_mat_sub(:); %gmat \ init_mat_sub(:);
        kern_stack{cwin} = kern; % Store the kernel
    end   
end