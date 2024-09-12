function init_paths(expName)
    % Load config file
    config();  % This will set rootDir in the base workspace

    % Access rootDir from the base workspace
    rootDir = evalin('base', 'rootDir');

    cd(rootDir);

    % Define paths
    commonDir = fullfile(rootDir, 'Common');
    expDir = fullfile(rootDir, 'Experiments', expName);

    % Project folder structure
    folders = {
        fullfile(expDir, 'Scripts')
        fullfile(expDir, 'Results')
        %fullfile(expDir, 'Config') %ideally would be good for storing
        %imaging params and plotting prefs for this data, rather than in
        %each file
    };

    % Create the project directory structure if it doesn't exist
    for i = 1:length(folders)
        if ~isfolder(folders{i})
            mkdir(folders{i});
            fprintf('Created folder: %s\n', folders{i});
        end
    end

    % Adding common paths
    addpath(genpath(commonDir));

    % Adding project-specific paths
    addpath(fullfile(expDir, 'Scripts'));

    % don't want to add data paths because might be name degeneracies

    % set other useful global variables 
    resultsDir = fullfile(expDir, 'Results');
    rawDataDir = fullfile(rootDir, 'Data', 'Raw');
    procDataDir = fullfile(rootDir, 'Data', 'Processed');
    customDataDir = fullfile(rootDir, 'Data', 'CustomDatasets');

    assignin('base', 'resultsDir', resultsDir);
    assignin('base', 'rawDataDir', rawDataDir);
    assignin('base', 'procDataDir', procDataDir);
    assignin('base', 'customDataDir', customDataDir);


    % Save the path for the current session
    savepath;

    % Display confirmation
    disp(['Paths successfully added and project initialized for: ', expName]);
end
