clear all;

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

chosen_exp_name = exp_name1; 
chosen_folder_name = projectdata1; 
data_string = fullfile(chosen_folder_name, 'Raw', [chosen_exp_name, '.tnt']);
outpath = fullfile(chosen_folder_name, 'Processed/tnt/',['tnt_preprocessed_data_', chosen_exp_name, '_FORMATTED.mat']);


%projectdata = './Projects/editor_tf_fits/Data';
%exp_name = 'fulldataset_CCmode_noFilter_halbachcylinder_paperphantom_4Rx_singlegpa65_8avg_run1'; % testing on this old file
%data_string = fullfile(projectdata, 'Raw/20240710', [exp_name, '.tnt']);
%outpath = fullfile(projectdata, 'Processed/tnt/',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);



% Parameters
VISUALIZE = 1; 
Nc = 4; % Number of coils
Necho = 1; % Number of echoes per coil
Nro = 256; % Number of readout points 
Nbuffer = 0;
Navg = 1; %repetitions in 2D, adjacent in time
Ncalib = 1; 
N2d = Navg * Ncalib;
Nfe = 40; %number of echo train sequences, this # + 1 should be divisible into the last index
Nrepeats = 2; % repetitions in 4d, of whole experiment


% Check if preprocessed data exists so don't do many times
if exist(outpath, 'file') && false
    load(outpath); 
else
    % Read and preprocess data
    new_preprocesstnt(data_string, outpath, Nc, Necho, Nro, Nbuffer, N2d, Nrepeats, Nfe, VISUALIZE);
end