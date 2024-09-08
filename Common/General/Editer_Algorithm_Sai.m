function Editer_Algorithm_Sai(dataFilePath)
    
    % EDITER ALGORITHM 
    %
    % Input : kspace data with Nc = 3 emi detectors and 1 primary coil
    % Modify to change # of emi detectors with "Nc" and commenting out extra
    % "dftmp" and "df#p" 
    % Modify from 2D to 3D data by adding extra for loop for different slices
    %%%%
    
    close all;
    %clear;
    clc;
    pwd
    
    data = load(dataFilePath); % helps with dynamic loading
    %load('./8598/data_EMI_8598.mat')
    
    %% image size
    
    % Determine the number of detectors
    detectorNames = fieldnames(data);
    detectorNames = detectorNames(startsWith(detectorNames, 'datanoise_fft_'));
    Nc = length(detectorNames);
    
    % Image size
    ncol = size(data.datafft, 1);
    nlin = size(data.datafft, 2);
    %%%%%%%%%%%%%%%%%%%%%%
    %% Initial pass using single PE line (Nw = 1)
    ksz_col = 0; % Deltakx = 1
    ksz_lin = 1; % Deltaky = 1
    
    %% kernels across pe lines
    kern_pe = zeros( Nc * (2*ksz_col+1) * (2*ksz_lin+1), nlin);
        
    for clin = 1:nlin
        
        noise_mat = [];
        
        pe_rng = clin;
        
        % Pad arrays for each detector
        paddedData = cell(Nc, 1);
        for d = 1:Nc
            paddedData{d} = padarray(data.(detectorNames{d})(:, pe_rng), [ksz_col ksz_lin]);
        end
        %df1p = padarray(ksp_noisedata_ch1(:,pe_rng), [ksz_col ksz_lin]);
        %df2p = padarray(ksp_noisedata_ch3(:,pe_rng), [ksz_col ksz_lin]);
        %df3p = padarray(ksp_noisedata_ch4(:,pe_rng), [ksz_col ksz_lin]);
            
        % Construct noise matrix
        for col_shift = -ksz_col:ksz_col
            for lin_shift = -ksz_lin:ksz_lin
                for d = 1:Nc
                    dftmp = circshift(paddedData{d}(:,:), [col_shift, lin_shift]);
                    noise_mat = cat(3, noise_mat, dftmp(ksz_col+1:end-ksz_col, ksz_lin+1:end-ksz_lin));
                end
            end
        end
        
        %for col_shift = [-ksz_col:ksz_col]
        %    for lin_shift = [-ksz_lin:ksz_lin]
        %        
        %        dftmp = circshift(df1p(:,:), [col_shift, lin_shift]);
        %        noise_mat= cat(3, noise_mat, dftmp(ksz_col+1:end-ksz_col, ksz_lin+1:end-ksz_lin));
        %        
        %        dftmp = circshift(df2p(:,:), [col_shift, lin_shift]);
        %        noise_mat= cat(3, noise_mat, dftmp(ksz_col+1:end-ksz_col, ksz_lin+1:end-ksz_lin));
        %        
        %        dftmp = circshift(df3p(:,:), [col_shift, lin_shift]);
        %        noise_mat= cat(3, noise_mat, dftmp(ksz_col+1:end-ksz_col, ksz_lin+1:end-ksz_lin));
        %    end
        %end
          
        %%%%%%%%%%%
        %% kernels
        gmat = reshape(noise_mat, size(noise_mat,1) * size(noise_mat,2), size(noise_mat,3));
        
        init_mat_sub = data.datafft(:,pe_rng);
    %     kern = gmat \ init_mat_sub(:);
        kern = pinv(gmat)*init_mat_sub(:);
        
        kern_pe(:,clin) = kern;
            
    end
    
    %%%%%%%%%%
    %% look at correlation between the kernels
    
    kern_pe_normalized = zeros(size(kern_pe));
    for clin = 1:nlin
    
        kern_pe_normalized(:,clin) = kern_pe(:,clin) / norm(kern_pe(:,clin));
    
    end
    
    kcor = kern_pe_normalized'  * kern_pe_normalized;
    
    %% threshold 
    kcor_thresh = abs(kcor) > 5e-1;
    
    %% start with full set of lines
    aval_lins = [1:nlin];
    
    %% window stack
    win_stack = cell(nlin, 1);
    
    cwin = 1;
    while (~isempty(aval_lins))
    
            clin = min(aval_lins);
            pe_rng = [clin:clin+max(find(kcor_thresh(clin, clin:end)))-1];
            
            win_stack{cwin} = pe_rng;
            aval_lins = sort(setdiff(aval_lins, pe_rng), 'ascend');
        
            cwin = cwin + 1;
    end
    
    %% drop the empty entries
    win_stack = win_stack(1:cwin-1);
        
    ksz_col = 0; % Deltakx
    ksz_col = 7; % Deltakx
    ksz_lin = 0; % Deltaky
    
    %% solution kspace
    gksp = zeros(ncol, nlin);
    
    for cwin = 1:length(win_stack)
        
        noise_mat = [];
        
        pe_rng = win_stack{cwin};

        % Pad arrays for each detector
        paddedData = cell(Nc, 1);
        for d = 1:Nc
            paddedData{d} = padarray(data.(detectorNames{d})(:, pe_rng), [ksz_col ksz_lin]);
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
        
        %df1p = padarray(ksp_noisedata_ch1(:,pe_rng), [ksz_col ksz_lin]);
        %df2p = padarray(ksp_noisedata_ch3(:,pe_rng), [ksz_col ksz_lin]);
        %df3p = padarray(ksp_noisedata_ch4(:,pe_rng), [ksz_col ksz_lin]);
        %
        %for col_shift = [-ksz_col:ksz_col]
        %    for lin_shift = [-ksz_lin:ksz_lin]
        %        
        %        dftmp = circshift(df1p(:,:), [col_shift, lin_shift]);
        %        noise_mat= cat(3, noise_mat, dftmp(ksz_col+1:end-ksz_col, ksz_lin+1:end-ksz_lin));
        %        
        %        dftmp = circshift(df2p(:,:), [col_shift, lin_shift]);
        %        noise_mat= cat(3, noise_mat, dftmp(ksz_col+1:end-ksz_col, ksz_lin+1:end-ksz_lin));
        %        
        %        dftmp = circshift(df3p(:,:), [col_shift, lin_shift]);
        %        noise_mat= cat(3, noise_mat, dftmp(ksz_col+1:end-ksz_col, ksz_lin+1:end-ksz_lin));
        %    end
        %end
        
        
        %%%%%%%%%%%
        %% kernels
        gmat = reshape(noise_mat, size(noise_mat,1) * size(noise_mat,2), size(noise_mat,3));
        
        init_mat_sub = data.datafft(:,pe_rng);
        kern = pinv(gmat)*init_mat_sub(:);%gmat \ init_mat_sub(:);
            
        %% put the solution back
        tosub = reshape(gmat * kern, ncol, length(pe_rng));
        gksp(:,pe_rng) = init_mat_sub - tosub;
        
    end
    
    corr_img_opt_toep = fftshift(fftn(fftshift(gksp)));

    % future, possibly accept input for range, or just have user local copy
    % and edit hardcode
    x_range = [150:350];
    y_range = [1:101];
    x_range = 1:ncol;
    y_range = 1:nlin;

    figure;
    t = tiledlayout(1,3,'TileSpacing','Compact','Padding','Compact');
    nexttile
    uncorr = fftshift(fftn(fftshift(data.datafft)));

    imagesc(flipud(rot90(abs(uncorr(x_range,y_range)))));  colormap gray; colorbar; %caxis([0 4e5]);
    axis equal; 
    axis tight;
    title([' primary uncorrected']);
    nexttile
    imagesc(flipud(rot90(abs(corr_img_opt_toep(x_range,y_range))))); colormap gray; colorbar; %caxis([0 4e5]);
    axis equal; 
    axis tight;  
    title([' corrected with EDITER' ]); 
    nexttile
    imagesc(flipud(rot90(abs(uncorr(x_range,y_range))))-flipud(rot90(abs(corr_img_opt_toep(x_range,y_range)))));
    colormap gray; colorbar; %caxis([0 4e5]);
    axis equal; 
    axis tight; 
    title([' difference image' ]);
    %set(gcf,'position',[378 555 1010 265]);
    %set(gcf,'position',[378 555 1010 265]);
    
    erms = rms(abs(uncorr(:)-corr_img_opt_toep(:)))
end
    

    