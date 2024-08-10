function [corrected_img, corrected_ksp] = inference_editer2d(combined_data, kern_stack, win_stack, ksz_col_LATE, ksz_lin_LATE)
    % Apply kernel to new data
    
    % Parameters
    Nc = size(combined_data, 3) - 1; % Number of noise detectors
    ncol = size(combined_data, 1);
    nlin = size(combined_data, 2);
    
    % Initialize corrected k-space
    gksp = zeros(ncol, nlin);
    
    % Apply kernel to each window
    for cwin = 1:length(win_stack)
        noise_mat = [];
        kern = kern_stack{cwin}; % read in kernel 
        pe_rng = win_stack{cwin};


        % Pad arrays for each detector
        paddedData = cell(Nc, 1);
        for d = 1:Nc
            paddedData{d} = padarray(combined_data(:, pe_rng, d + 1), [ksz_col_LATE ksz_lin_LATE]);
        end

        % Construct noise matrix
        for col_shift = -ksz_col_LATE:ksz_col_LATE
            for lin_shift = -ksz_lin_LATE:ksz_lin_LATE
                for d = 1:Nc
                    dftmp = circshift(paddedData{d}(:,:), [col_shift, lin_shift]);
                    noise_mat = cat(3, noise_mat, dftmp(ksz_col_LATE + 1:end - ksz_col_LATE, ksz_lin_LATE + 1:end - ksz_lin_LATE));
                end
            end
        end
        
        % Put the solution back
        gmat = reshape(noise_mat, size(noise_mat, 1) * size(noise_mat, 2), size(noise_mat, 3));
        init_mat_sub = combined_data(:, pe_rng, 1);
        
        tosub = reshape(gmat * kern, ncol, length(pe_rng));
        gksp(:, pe_rng) = init_mat_sub - tosub;
    end    

    corrected_ksp = gksp; 
    corrected_img = ifftshift(ifftn(ifftshift(gksp)));
end
