% on extremity scanner we only did 2d scans, and auto-averaging 
function preprocess_cameleon(raw_data_path, outpath, Nc, Nro, Nfe, options)

    %----------------------
    %-- Parameters
    %----------------------
    matrix1d     = Nro; %  MATRIX_DIMENSION_1D
    matrix2d     = Nfe; % MATRIX_DIMENSION_2D
    matrix3d     = 1; % MATRIX_DIMENSION_3D
    matrix4d     = 1; % MATRIX_DIMENSION_4D
    ncoils  = Nc; % RECEIVER_COUNT 
    PRIMARY_COIL_NUMBER = 2; 


    %----------------------
    %-- Read Data
    %----------------------

    file = fopen(raw_data_path);
    data = fread(file, 'float32','b'); 
    size(data)
    fclose(file);
    Nc * Nro * Nfe * 2

    % original formatting
    ksp = zeros(matrix1d,matrix2d,ncoils);
    data = reshape(data, 2, matrix1d , matrix2d , matrix3d , matrix4d , ncoils); 
    data = complex(data(2,:,:,:,:,:), data(1,:,:,:,:,:));   
    z = size(data); 
    for nc = 1:ncoils
        ksp(:,:,nc)= reshape(data(:,:,:,nc),z(2:end-1)); % 1x256x256 complex
    end

    % set to my formatting
    ksp = reshape(ksp, matrix1d, matrix2d, matrix3d, 1, 1, ncoils); 
    % bump to 3d if necessary
    if size(ksp, 3) == 1
        ksp = cat(3, ksp, ksp);  % Duplicate the data along the third dimension
    end
    size(ksp)

    % order the primary at the beginning
    ksp_first = ksp(:, :, :, :, :, 1);  % Extract the first coil
    ksp_primary = ksp(:, :, :, :, :, PRIMARY_COIL_NUMBER);  % Extract the primary coil
    ksp(:, :, :, :, :, 1) = ksp_primary;
    ksp(:, :, :, :, :, PRIMARY_COIL_NUMBER) = ksp_first;


    SmartSaveMatData(ksp, outpath); % creates folders if necessary 
    DefaultVisualization(ksp, options);
end 
