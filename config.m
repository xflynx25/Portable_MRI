% config.m
function config()
    % Define root directory
    %rootDir = '/Users/JF1183/Documents/martinos_docs';
    rootDir = '/Users/jflyn/Documents/martinos_docs_windows';

    % Make rootDir accessible globally
    assignin('base', 'rootDir', rootDir);
end
