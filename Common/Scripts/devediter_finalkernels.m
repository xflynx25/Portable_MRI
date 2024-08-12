function [kern_stack, win_stack, ksz_col, ksz_lin] = devediter_finalkernels(combined_data, win_stack, ksz_col, ksz_lin)
    % Phase 3: using the temporal clusters, compute optimal kernels 
    % TODO: refactor for ky proper use availability 


    % variables we need to recompute
    Nc = size(combined_data, 3) - 1;  % Number of noise detectors

    % solution kspace
    kern_stack = cell(length(win_stack), 1);
    
    for cwin = 1:length(win_stack)
        noise_mat = [];
        pe_rng = win_stack{cwin};

        % Pad arrays for each detector
        paddedData = cell(Nc, 1);
        for d = 1:Nc
            paddedData{d} = padarray(combined_data(:, pe_rng, d + 1), [ksz_col ksz_lin]);
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

