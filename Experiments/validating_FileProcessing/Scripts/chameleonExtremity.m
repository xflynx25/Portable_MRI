% CALLING chameleon PROCESSING, SPECIFY FOLDER, EXP NAME, AND ACQ PARAMS 

close all; 

% select an option here 
data_folder = 'ExtremityScanner/20240503'; 
experimentName = '8642';

% Parameters
PRINT_FOLDER_CONTENTS = 0;
Nc = 4; % Number of coils
Nro = 128; % Number of readout points 
Nfe = 128; %number of echo train sequences, this # + 1 should be divisible into the last index

options.visualize = 1;
%options.SLICE = 2;  % Overriding just the SLICE value
options.IMAGE_SCALE = 1;  % Custom image scale
options.KSPACE_SCALE = 0; 



% formatting filepaths 
rawDataDir = evalin('base', 'rawDataDir');
procDataDir = evalin('base', 'procDataDir');
data_string = fullfile(rawDataDir, data_folder, [experimentName, '/data.dat']);
outpath = fullfile(procDataDir, data_folder, [experimentName, '_FORMATTED.mat']);

% view options in the folder instead of running 
if PRINT_FOLDER_CONTENTS == 1
    ListFilesInFolder(fullfile(evalin('base', 'rawDataDir'), data_folder))
    error('get rekked');
end


% Check if preprocessed data exists so don't do many times
if exist(outpath, 'file') && false
    load(outpath); 
else
    % Read and preprocess data
    preprocess_cameleon(data_string, outpath, Nc, Nro, Nfe, options);
end