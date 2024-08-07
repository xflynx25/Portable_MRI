% Example input data
combined_data = rand(5, 5, 3); % 5x5 matrix with 3 detectors
ksz_col = 1;
ksz_lin = 1;
Nc = size(combined_data, 3) - 1; % 2 noise detectors
pe_rng = 3; % example phase encoding line

% Pad arrays for each detector
paddedData = cell(Nc, 1);
for d = 1:Nc
    paddedData{d} = padarray(combined_data(:, pe_rng, d + 1), [ksz_col ksz_lin]);
end

% Display original and padded data for visualization
disp('Original Data:');
disp(combined_data(:, pe_rng, 2));
disp('Padded Data:');
disp(paddedData{1});

% Construct noise matrix
noise_mat = [];
for col_shift = -ksz_col:ksz_col
    for lin_shift = -ksz_lin:ksz_lin
        for d = 1:Nc
            % Apply shift
            dftmp = circshift(paddedData{d}(:,:), [col_shift, lin_shift]);
            
            % Extract central part and concatenate
            noise_mat = cat(3, noise_mat, dftmp(ksz_col+1:end-ksz_col, ksz_lin+1:end-ksz_lin));
            
            % Display shifted data for visualization
            disp(['Shift (', num2str(col_shift), ', ', num2str(lin_shift), ') for Detector ', num2str(d)]);
            disp(dftmp);
            disp('Central part after removing padding:');
            disp(dftmp(ksz_col+1:end-ksz_col, ksz_lin+1:end-ksz_lin));
        end
    end
end

% Display the constructed noise matrix
disp('Constructed Noise Matrix:');
disp(noise_mat);
