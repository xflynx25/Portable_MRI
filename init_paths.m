function init_paths(projectName)
    rootDir = '/Users/jflyn/Documents/martinos_docs';
    rootDir = '/Users/JF1183/Documents/martinos_docs';
    rootDir = '/Users/jflyn/Documents/martinos_docs_windows';
    cd(rootDir);

    % Define paths
    commonDir = fullfile(rootDir, '/Common');
    projectDir = fullfile(rootDir, 'Projects', projectName);

    % Project folder structure
    folders = {
        fullfile(projectDir, 'Data', 'Raw')
        fullfile(projectDir, 'Data', 'Processed')
        fullfile(projectDir, 'Scripts', 'FileProcessing')
        fullfile(projectDir, 'Scripts', 'Other')
        fullfile(projectDir, 'Results')
        fullfile(projectDir, 'Config')
    };

    % Create the project directory structure if it doesn't exist
    for i = 1:length(folders)
        if ~isfolder(folders{i})
            mkdir(folders{i});
            fprintf('Created folder: %s\n', folders{i});
        end
    end

    % Adding common paths
    addpath(fullfile(commonDir, 'Scripts'));
    addpath(fullfile(commonDir, 'Scripts/Plotting'));
    addpath(fullfile(commonDir, 'Helpers'));
    addpath(fullfile(commonDir, 'Helpers', 'matlab_basic_functions'));
    addpath(fullfile(commonDir, 'Helpers', 'john_helpers'));
    addpath(fullfile(commonDir, 'Helpers', 'matlab_basic_functions', 'ReadData'));
    addpath(fullfile(commonDir, 'Helpers', 'wavelet-coherence-master'));

    % Adding project-specific paths
    addpath(fullfile(projectDir, 'Scripts', 'FileProcessing'));
    addpath(fullfile(projectDir, 'Scripts', 'Other'));

    % Add data and results directories if needed
    addpath(fullfile(projectDir, 'Data', 'Raw'));
    addpath(fullfile(projectDir, 'Data', 'Processed'));
    addpath(fullfile(projectDir, 'Results'));

    % Save the path for the current session
    savepath;

    % Display confirmation
    disp(['Paths successfully added and project initialized for: ', projectName]);
end
