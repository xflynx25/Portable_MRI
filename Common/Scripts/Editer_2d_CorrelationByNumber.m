function [corrected_img, corrected_ksp] = Editer_2d_transform(combined_data, varargin)
    % this deals with multi-detector, returns the transformed data
    % same as editer_algorithm_sai but without plotting and instead is returning
    % things
    % by static we mean Nw = 1
    % expect data in this format: x by y by n_detectors

    %%%%% user setup   
    ksz_col_EARLY = 0;%3; % Deltakx = 1
    ksz_lin_EARLY = 0;%3; % Deltaky = 1
    ksz_col_LATE = 7; 
    ksz_lin_LATE = 1;%0; 
    fprintf('whats up');
    initial_threshold = 5e-3;
    step_threshold = 1e-3;
    max_threshold = .99;

    %%%%% parameters 
    clc;

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

    disp('ineditoer')
    
    %% Normalization and correlation calculation
    kern_pe_normalized = zeros(size(kern_pe));
    for clin = 1:nlin
        kern_pe_normalized(:, clin) = kern_pe(:, clin) / norm(kern_pe(:, clin));
    end
    kcor = kern_pe_normalized' * kern_pe_normalized;

    disp('check2a')

    %% Adaptive threshold adjustment
    CORRELATION_EPS = initial_threshold;
    desired_groupings = 7; % Desired number of groupings (you can set this as needed)
    num_groupings = 0;

    while num_groupings < desired_groupings && CORRELATION_EPS <= max_threshold
        kcor_thresh = abs(kcor) > CORRELATION_EPS;
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
        
        win_stack = win_stack(1:cwin - 1);
        num_groupings = length(win_stack);

        if num_groupings < desired_groupings
            CORRELATION_EPS = CORRELATION_EPS + step_threshold;
        end
    end

    disp('check2b')
    
    ksz_col = ksz_col_LATE; % 0 or 7 typically
    ksz_lin = ksz_lin_LATE; 
    
    disp('grody')
    
    %% Visualization: Heatmap of the correlation matrix with highlights
    VIS = 0;
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

        % Define a set of colors for different groups
        colors = lines(length(win_stack));  % 'lines' colormap has good distinct colors
        
        % Highlight the chosen sections based on the window stack
        for i = 1:length(win_stack)
            color = colors(i, :);  % Select color for current group
            for j = 1:length(win_stack{i})
                x = win_stack{i}(j);
                for k = j:length(win_stack{i})
                    y = win_stack{i}(k);
                    rectangle('Position', [x-0.5, y-0.5, 1, 1], 'EdgeColor', color, 'LineWidth', 1.5);
                end
            end
        end
        hold off;
    end

    disp('third')

    %% Solution kspace
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

        kern = pinv(gmat) * init_mat_sub(:); %gmat \ init_mat_sub(:);
            
        %% Put the solution back
        tosub = reshape(gmat * kern, ncol, length(pe_rng));
        gksp(:, pe_rng) = init_mat_sub - tosub;
    end    
    
    disp('fourth')
    corrected_ksp = gksp; 
    corrected_img = ifftshift(ifftn(ifftshift(gksp)));

    % Plot to check ourselves
    disp('Plotting results...');

    x_range = 1:ncol;
    y_range = 1:nlin;
    
    % Plots
    if ~isempty(varargin) && length(varargin) >= 1
        is_plotting = varargin{1};
        if length(varargin) >= 2
            daspect = varargin{2};
        end
        if is_plotting
            primary_coil = combined_data(:, :, 1); 
            uncorrected_ksp = primary_coil;
            uncorrected_img = ifftshift(ifftn(ifftshift(primary_coil)));

            % 1. Raw values
            plot_simple_editer(combined_data(:, :, 1), corrected_img, x_range, y_range)
            % 2. Adjusted to be a square
            plot_editer_advanced(uncorrected_img, corrected_img, 0, x_range, y_range, daspect)
            plot_editer_advanced(uncorrected_img, corrected_img, .5, x_range, y_range, daspect)
            % 3. Square, on logarithmic scale
            plot_editer_advanced(uncorrected_img, corrected_img, 1, x_range, y_range, daspect)
            % 4. Square, on multi-logarithmic scale
            plot_editer_advanced(uncorrected_img, corrected_img, 8, x_range, y_range, daspect)
            % 5. We can plot the kspace too
            plot_editer_advanced(uncorrected_ksp, corrected_ksp, 1, x_range, y_range, daspect)
        end
    end
end
