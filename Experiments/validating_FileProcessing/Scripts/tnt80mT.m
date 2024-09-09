% CALLING TNT PROCESSING, SPECIFY FOLDER, EXP NAME, AND ACQ PARAMS 


% File paths and parameters
projectdata1 = './Projects/20240809/Data';
exp_name1 = 'with_blanket_test1'; 
exp_name1 = 'with_blanketgrounded_newgradOFF_doubleacquisition_test1'; 
%exp_name1 = '3Dsequence_2Dtable_averaging_echotrain_test1';
%exp_name1 = 'with_blanket_newgradON_test1'; 
%exp_name1 = 'noblanket_newgradON_test1'; 
exp_name1 = 'with_blanketgrounded_newgradON_doubleacquisition_test1'; 


projectdata2 = './Projects/20240807/Data';
exp_name2 = '3Dsequence_2Dtable_averaging_echotrain_newgradPOWEROFF_test1';
exp_name2 = 'calibration_doubleacq_morepoints'; 
exp_name2 = 'acquire_3d_twoandtwo_calibration_maxxx'; 


%projectdata = './Projects/editor_tf_fits/Data';
%exp_name = 'fulldataset_CCmode_noFilter_halbachcylinder_paperphantom_4Rx_singlegpa65_8avg_run1'; % testing on this old file
%data_string = fullfile(projectdata, 'Raw/20240710', [exp_name, '.tnt']);
%outpath = fullfile(projectdata, 'Processed/tnt/',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);




% select an option here 
data_folder = '80mT_Scanner/20240807'; 
experimentName = 'calibration_doubleacq_trial1';


% Parameters
PRINT_FOLDER_CONTENTS = 0;
Nc = 4; % Number of coils
Necho = 1; % Number of echoes per coil
Nro = 260; % Number of readout points 
Nbuffer = 4;
Navg = 1; %repetitions in 2D, adjacent in time
Ncalib = 2; 
N2d = Navg * Ncalib;
Nfe = 40; %number of echo train sequences, this # + 1 should be divisible into the last index
Nrepeats = 2; % repetitions in 4d, of whole experiment

options.visualize = 1;
%options.SLICE = 2;  % Overriding just the SLICE value
options.IMAGE_SCALE = 2;  % Custom image scale
options.KSPACE_SCALE = 1; 
options.CALIBRATION = 0; 



% formatting filepaths 
rawDataDir = evalin('base', 'rawDataDir');
procDataDir = evalin('base', 'procDataDir');
data_string = fullfile(rawDataDir, data_folder, [experimentName, '.tnt']);
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
    preprocess_tnt(data_string, outpath, Nc, Necho, Nro, Nbuffer, N2d, Nrepeats, Nfe, options);
end