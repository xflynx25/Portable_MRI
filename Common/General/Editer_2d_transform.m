function [corrected_img, corrected_ksp] = Editer_2d_transform(combined_data, varargin)
    % this deals with multi-detector, returns the transformed data
    % same as editer_algorithm_sai but without plotting and instead is returning
    % things
    % by static we mean Nw = 1
    % expect data in this format: x by y by n_detectors

    %%%%% user setup   
    ksz_col_EARLY = 0; %3; % Deltakx = 1
    ksz_lin_EARLY = 0; %3; % Deltaky = 1
    ksz_col_LATE = 7; 
    ksz_lin_LATE = 0; 
    CORRELATION_EPS = 0 + 5e-1;
    CORRELATION_EPS = 5e-1;%5e-1;

    %%%%% parameters 
    %clc;

    ksz_col = ksz_col_EARLY; 
    ksz_lin = ksz_lin_EARLY; 
    
    % Determine the number of detectors
    Nc = size(combined_data, 3) - 1;  % Number of noise detectors

    
    % Image size
    ncol = size(combined_data, 1);
    nlin = size(combined_data, 2);


    %%%% kernels across pe lines
    kern_pe = zeros( Nc * (2*ksz_col+1) * (2*ksz_lin+1), nlin);
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
        
        % kernels
        gmat = reshape(noise_mat, size(noise_mat, 1) * size(noise_mat, 2), size(noise_mat, 3));  
        init_mat_sub = combined_data(:, pe_rng, 1);
        kern = pinv(gmat) * init_mat_sub(:);        
        kern_pe(:, clin) = kern;  
    end
    

    %% Original code: normalization and correlation calculation
    kern_pe_normalized = zeros(size(kern_pe));
    for clin = 1:nlin
        kern_pe_normalized(:, clin) = kern_pe(:, clin) / norm(kern_pe(:, clin));
    end
    kcor = kern_pe_normalized' * kern_pe_normalized;
    
    % Threshold calculation
    kcor_thresh = abs(kcor) > CORRELATION_EPS;

    if false%~isempty(varargin)
        abs(kcor)
        corrected_img = true; 
        corrected_ksp = false;
        return
    end
    
    % Start with full set of lines
    aval_lins = 1:nlin;
    
    % Window stack
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

    ksz_col = ksz_col_LATE; % 0 or 7 typically
    ksz_lin = ksz_lin_LATE; 
   
    
    %% Visualization: Heatmap of the correlation matrix with highlights
    VIS = 1;
    if VIS == 1
        disp(win_stack)

        figure;
        imagesc(abs(kcor)); % Display the heatmap
        colormap('jet'); % Use a colormap
        colorbar; % Display the colorbar
        title('Correlation Matrix with Highlights');
        xlabel('Lines');
        ylabel('Lines');
        hold on;
        
        % Highlight the chosen sections based on the window stack
        for i = 1:length(win_stack)
            for j = 1:length(win_stack{i})
                x = win_stack{i}(j);
                for k = j:length(win_stack{i})
                    y = win_stack{i}(k);
                    rectangle('Position', [x-0.5, y-0.5, 1, 1], 'EdgeColor', 'black', 'LineWidth', .02);
                end
            end
        end
        hold off;
    end


    %% solution kspace
    gksp = zeros(ncol, nlin);
    
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

        %disp(size(init_mat_sub))
        %disp(size(gmat))

        kern = pinv(gmat) * init_mat_sub(:); %gmat \ init_mat_sub(:);
            
        %% put the solution back
        tosub = reshape(gmat * kern, ncol, length(pe_rng));
        gksp(:, pe_rng) = init_mat_sub - tosub;
    end    
    
    corrected_ksp = gksp; 
    %corrected_img = fftshift(fftn(fftshift(gksp)));    
    corrected_img = ifftshift(ifftn(ifftshift(gksp)));

    %test_fft_ifft(gksp);

    x_range = [1:256]; %[150:350];
    y_range = [1:256]; %[1:101];
    x_range = 1:ncol;
    y_range = 1:nlin;
    
    % plots
    if ~isempty(varargin) && length(varargin) >= 1
        is_plotting = varargin{1};
        if length(varargin) >= 2
            daspect = varargin{2};
        else
            daspect = -1; 
        end
        if is_plotting
            disp('Plotting results...');
            primary_coil = combined_data(:, :, 1); 
            uncorrected_ksp = primary_coil;
            uncorrected_img = ifftshift(ifftn(ifftshift(primary_coil)));
            %uncorrected_img = ifftshift(ifft2(ifftshift(primary_coil)));

            % 1. raw values
            %plot_simple_editer(combined_data(:, :, 1), corrected_img, x_range, y_range)
            % 2. adjusted to be a square
            %plot_editer_advanced(uncorrected_img, corrected_img, 0, x_range, y_range, daspect)
            %plot_editer_advanced(uncorrected_img, corrected_img, .5, x_range, y_range, daspect)
            % 3. square, on logarithmic scale
            %plot_editer_advanced(uncorrected_img, corrected_img, 2, x_range, y_range, daspect)
            % 4. square, on multi logarithmic scale
            %plot_editer_advanced(uncorrected_img, corrected_img, 8, x_range, y_range, daspect)
            % 5. we can plot the kspace too
            %plot_editer_advanced(uncorrected_ksp, corrected_ksp, 0, x_range, y_range, daspect)
            %plot_editer_advanced(uncorrected_ksp, corrected_ksp, 2, x_range, y_range, daspect)
            %plot_editer_advanced(uncorrected_ksp, corrected_ksp, 8, x_range, y_range, daspect)


            % custom choosing which
            fprintf('- Kspace - ')
            plot_editer_advanced(uncorrected_ksp, corrected_ksp, 0)
            fprintf('- Image - ')
            plot_editer_advanced(uncorrected_img, corrected_img, 1)
            %calculate_snr_saving2d(uncorrected_img, true);
            %calculate_snr_saving2d(corrected_img, true);
        end
    end

end