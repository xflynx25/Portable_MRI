function [corrected_img, corrected_ksp] = devediter_inference(combined_data, kern_stack, win_stack, ksz_col, ksz_lin)
    % Phase 4: using the kernels (model), predict on some data 
  

    % Parameters
    Nc = size(combined_data, 3) - 1; % Number of noise detectors
    ncol = size(combined_data, 1);
    nlin = size(combined_data, 2);
    
    % Initialize corrected k-space
    gksp = zeros(ncol, nlin);

    padded_combined_data = padarray(combined_data, [ksz_col ksz_lin 0]);
    
    % Apply kernel to each window
    for cwin = 1:length(win_stack)
        noise_mat = [];
        kern = kern_stack{cwin}; % read in kernel 
        pe_rng = win_stack{cwin};
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
        
        % Put the solution back
        gmat = reshape(noise_mat, size(noise_mat, 1) * size(noise_mat, 2), size(noise_mat, 3));
        init_mat_sub = combined_data(:, pe_rng, 1);
        
        tosub = reshape(gmat * kern, ncol, length(pe_rng));
        gksp(:, pe_rng) = init_mat_sub - tosub;
    end    

    corrected_ksp = gksp; 
    corrected_img = ifftshift(ifftn(ifftshift(gksp)));
end