function [starter_kernels] = devediter_initialfits(combined_data, W, ksz_col, ksz_lin)
    % Phase 1: find initial kernels 
    % TODO: implement ability to have ky with W = 1 
    % TODO: implement varying W parameter


    % Determine the number of detectors
    Nc = size(combined_data, 3) - 1;  % Number of noise detectors

    % Image size
    ncol = size(combined_data, 1);
    nlin = size(combined_data, 2);

    % Kernel computation across lines
    starter_kernels = zeros(Nc * (2*ksz_col+1) * (2*ksz_lin+1), nlin);
    padded_combined_data = padarray(combined_data, [ksz_col ksz_lin 0]);
    for clin = 1:nlin
        noise_mat = [];
        pe_rng = clin;
        
        % Pad arrays for each detector
        paddedData = cell(Nc, 1);
        for d = 1:Nc
            paddedData{d} = padded_combined_data(:, clin:clin+2*ksz_lin, d+1); 
        end

            
        % Construct noise matrix
        for col_shift = -ksz_col:ksz_col
            for lin_shift = -ksz_lin:ksz_lin
                for d = 1:Nc
                    dftmp = circshift(paddedData{d}(:,:), [col_shift, lin_shift]);
                    noise_mat = cat(3, noise_mat, dftmp(ksz_col+1:end-ksz_col, ksz_lin+1:end-ksz_lin));
                end
            end
        end
        
        % Compute kernels
        gmat = reshape(noise_mat, size(noise_mat, 1) * size(noise_mat, 2), size(noise_mat, 3));  
        init_mat_sub = combined_data(:, pe_rng, 1);
        kern = pinv(gmat) * init_mat_sub(:);        
        starter_kernels(:, clin) = kern;  
    end
end

