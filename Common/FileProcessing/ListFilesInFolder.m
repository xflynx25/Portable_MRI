function ListFilesInFolder(folderPath)
    % Check if the folder exists
    if exist(folderPath, 'dir')
        % Get list of all files and folders in the directory
        files = dir(folderPath);
        
        % Filter out '.' and '..' (current and parent directory references)
        files = files(~ismember({files.name}, {'.', '..'}));
        
        % Display the files
        fprintf('Files and folders in "%s":\n', folderPath);
        for i = 1:length(files)
            fprintf('%s\n', files(i).name);
        end
    else
        % Display error if folder does not exist
        fprintf('Folder "%s" does not exist.\n', folderPath);
    end
end
