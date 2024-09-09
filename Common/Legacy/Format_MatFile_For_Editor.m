function Format_MatFile_For_Editor(dataFilePath, primaryCoilName)
    % Load the data
    data = load(dataFilePath);
    
    % Determine the fieldnames
    fieldNames = fieldnames(data);
    
    % Ensure the primary coil field exists
    if ~ismember(primaryCoilName, fieldNames)
        error('The specified primary coil field does not exist in the data.');
    end
    
    % Rename the primary coil data to datafft
    data.datafft = data.(primaryCoilName);
    data = rmfield(data, primaryCoilName);
    
    % Initialize noise data counter
    noiseCounter = 1;
    
    % Rename noise data channels to datanoise_fft_1, datanoise_fft_2, etc.
    for i = 1:length(fieldNames)
        if ~strcmp(fieldNames{i}, primaryCoilName)
            newFieldName = sprintf('datanoise_fft_%d', noiseCounter);
            data.(newFieldName) = data.(fieldNames{i});
            data = rmfield(data, fieldNames{i});
            noiseCounter = noiseCounter + 1;
        end
    end
    
    % Save the transformed data back to file
    [pathstr, name, ext] = fileparts(dataFilePath);
    newFileName = fullfile(pathstr, [name, '_FORMATTED', ext]);
    save(newFileName, '-struct', 'data');
    
    disp(['Transformed data saved to ', newFileName]);

    % make combined? 
    augment_matfile_with_combined(newFileName);
end
