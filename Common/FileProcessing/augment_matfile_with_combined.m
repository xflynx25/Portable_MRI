function augment_matfile_with_combined(filepath)
    % Load the data from the specified file
    data = load(filepath);
    
    % Initialize the combined data array
    detectorNames = fieldnames(data);
    primary_data = data.datafft;
    [ncol, nlin, ~] = size(primary_data);
    
    % Find the number of noise detectors
    noise_detectors = detectorNames(startsWith(detectorNames, 'datanoise_fft_'));
    Nc = length(noise_detectors) + 1; % Including the primary detector

    % Create a combined data array
    if ndims(primary_data) == 4 %N2d, averages or calibration + 3d
        % 3D data
        [ncol, nlin, nslc, n2d] = size(primary_data);
        datafft_combined = zeros(ncol, nlin, nslc, Nc, n2d);
        datafft_combined(:, :, :, 1, :) = primary_data;
        for i = 1:length(noise_detectors)
            datafft_combined(:, :, :, i+1, :) = data.(noise_detectors{i});
        end
    end

    if ndims(primary_data) == 3
        % 3D data
        [ncol, nlin, nslc] = size(primary_data);
        datafft_combined = zeros(ncol, nlin, nslc, Nc);
        datafft_combined(:, :, :, 1) = primary_data;
        for i = 1:length(noise_detectors)
            datafft_combined(:, :, :, i+1) = data.(noise_detectors{i});
        end
    end

    if ndims(primary_data) == 2
        % 2D data
        datafft_combined = zeros(ncol, nlin, Nc);
        datafft_combined(:, :, 1) = primary_data;
        for i = 1:length(noise_detectors)
            datafft_combined(:, :, i+1) = data.(noise_detectors{i});
        end
    end
    

    % if single echo need to double to deal with singleton
    % copy the whole thing and put it in the 3rd axis. 
    if ndims(primary_data) > 2 && size(datafft_combined, 3) == 1
        datafft_combined = cat(3, datafft_combined, datafft_combined);
    end


    % Add the combined data to the original data structure
    data.datafft_combined = datafft_combined;
    
    % Save the augmented data back to the file
    save(filepath, '-struct', 'data');
    
    fprintf('Data augmented with combined detector data and saved to %s\n', filepath);
end
