function SmartSaveMatData(array, outpath)
    % Check if the output directory exists, create it if it doesn't
    [outputDir, ~, ~] = fileparts(outpath);
    
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);  % Create the directory if it doesn't exist
        disp(['Created directory: ', outputDir]);
    end
    
    % Initialize a structure to store the data
    data_struct = struct();
    data_struct.('datafft_combined') = array;

    % Save the structure to the specified output file
    save(outpath, '-struct', 'data_struct');
    disp(['Processed data saved to ', outpath]);
end
