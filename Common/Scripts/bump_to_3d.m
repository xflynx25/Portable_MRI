function bump_to_3d(filepath)
    % DUPLICATES ONCE BECAUSE AUTOMATIC COMPRESSION OF ENDING SINGLETON DIMENSIONS
    % OTHERWISE
    % Load the data from the specified file
    data = load(filepath);
    
    % Create a structure to store the 3D data
    data3d = struct();
    
    % Loop through each variable and add the third dimension
    variableNames = fieldnames(data);
    for i = 1:length(variableNames)
        varName = variableNames{i};
        varData = data.(varName);
        
        % Check if the variable is a 2D matrix
        if ismatrix(varData) && ndims(varData) == 2
            % Print original size for debugging
            fprintf('Original size of %s: %s\n', varName, mat2str(size(varData)));
            
            % Add the third dimension with size 2
            varData3d = reshape(varData, size(varData, 1), size(varData, 2), 1);
            varData3d = cat(3, varData3d, varData3d);  % Duplicate the data along the third dimension
            data3d.(varName) = varData3d;
            
            % Print new size for debugging
            fprintf('New size of %s: %s\n', varName, mat2str(size(varData3d)));
        else
            % Print size for non-2D data
            fprintf('Non-2D data %s: %s\n', varName, mat2str(size(varData)));
            
            % If not 2D, keep the data as is
            data3d.(varName) = varData;
        end
    end
    
    % Create the new filename with '_3d.mat' appended
    [pathstr, name, ext] = fileparts(filepath);
    ending = strcat(name, '_3d', ext); 
    newFileName = fullfile(pathstr, ending);

    % Save the 3D data to the new file
    save(newFileName, '-struct', 'data3d');
    
    fprintf('3D data saved to %s\n', newFileName);
end
