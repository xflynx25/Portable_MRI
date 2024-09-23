function [kern_stack, win_stack, ksz_col, ksz_lin] = training_editer2d(combined_data)
    % Training function to find the kernel and parameters
    
    % User setup
    ksz_col_EARLY = 0; % Default values
    ksz_lin_EARLY = 0;
    ksz_col_LATE = 7;
    ksz_lin_LATE = 1;
    CORRELATION_EPS = 5e-1; % Default value

    % Parameters
    ksz_col = ksz_col_EARLY; 
    ksz_lin = ksz_lin_EARLY; 
    
    % Determine the number of detectors
    Nc = size(combined_data, 3) - 1;  % Number of noise detectors

    % Image size
    ncol = size(combined_data, 1);
    nlin = size(combined_data, 2);

    % Kernel computation across lines
    kern_pe = zeros(Nc * (2*ksz_col+1) * (2*ksz_lin+1), nlin);
    for clin = 1:nlin
        noise_mat = [];
        pe_rng = clin;
        
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
                    noise_mat = cat(3, noise_mat, dftmp(ksz_col+1:end-ksz_col, ksz_lin+1:end-ksz_lin));
                end
            end
        end
        
        % Compute kernels
        gmat = reshape(noise_mat, size(noise_mat, 1) * size(noise_mat, 2), size(noise_mat, 3));  
        init_mat_sub = combined_data(:, pe_rng, 1);
        kern = pinv(gmat) * init_mat_sub(:);        
        kern_pe(:, clin) = kern;  
    end

    % Normalize kernels and compute correlation matrix
    kern_pe_normalized = zeros(size(kern_pe));
    for clin = 1:nlin
        kern_pe_normalized(:, clin) = kern_pe(:, clin) / norm(kern_pe(:, clin));
    end
    kcor = kern_pe_normalized' * kern_pe_normalized;
    
    % Threshold calculation
    kcor_thresh = abs(kcor) > CORRELATION_EPS;

    % Determine window stack
    aval_lins = 1:nlin;
    win_stack = cell(nlin, 1);
    cwin = 1;
    
    while ~isempty(aval_lins)
        clin = min(aval_lins);
        pe_rng = clin:clin + max(find(kcor_thresh(clin, clin:end))) - 1;
        win_stack{cwin} = pe_rng;
        aval_lins = sort(setdiff(aval_lins, pe_rng), 'ascend');
        cwin = cwin + 1;
    end
    
    % Drop the empty entries
    win_stack = win_stack(1:cwin - 1);

    % second pass through
    ksz_col = ksz_col_LATE; % 0 or 7 typically
    ksz_lin = ksz_lin_LATE; 

    % solution kspace
    kern_stack = cell(length(win_stack), 1);
    %kern_stack = zeros(ncol, nlin);
    
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

