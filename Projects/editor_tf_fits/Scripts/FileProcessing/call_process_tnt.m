clear all;

% File paths and parameters
projectdata = './Projects/editor_tf_fits/Data';
data_string = fullfile(projectdata, 'Raw/John_tnt_data','cylinder_test_activeTR_2Rx_datasorted.tnt');
outpath = fullfile(projectdata, 'Processed/tnt','tnt_preprocessed_data.mat');

exp_name = 'zgrad_40gain_4coil_4avg_run1';
data_string = fullfile(projectdata, 'Raw/July2-24_flashdrive/July2-24/', [exp_name, '.tnt']);
outpath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '.mat']);

exp_name = 'fulldataset_CCmode_noFilter_halbachcylinder_paperphantom_4Rx_singlegpa65_8avg_run1';
data_string = fullfile(projectdata, 'Raw/20240710/', [exp_name, '.tnt']);
outpath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '.mat']);

% on the public computer 
exp_name = 'fulldataset_CCmode_noFilter_halbachcylinder_paperphantom_4Rx_singlegpa65_8avg_run1';
data_string = 'C:\Users\Public\Data\20240730\2Dsequence_2Dtable_averaging_singleecho_4rx_1repeat_260.tnt';   %% change N2d to 4
outpath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '.mat']);


exp_name = '2Dsequence_2Dtable_averaging_singleecho_trigearly_4rx_3repeat_260_gain60_ball_5th_trial1';
exp_name = '2Dsequence_2Dtable_calibration_singleecho_trigearly_4rx_1repeat_260_gain60_ball_5th_trial2';
%exp_name = 'builtin_averages';
read_folder = 'C:\Users\Public\Data\20240805';
data_string = fullfile(read_folder, [exp_name, '.tnt']);
outpath = fullfile(projectdata, 'Processed/tnt/',['tnt_preprocessed_data_', exp_name, '.mat']);



% Parameters
PRIMARY_COIL_NUMBER = 1; 
Nc = 4; % Number of coils
Necho = 1; % Number of echoes per coil
Nro = 260; % Number of readout points 
Navg = 1; 
Ncalib = 2; 
N2d = Navg * Ncalib;
Nbuffer = 4;


% Check if preprocessed data exists so don't do many times
if exist(outpath, 'file') && false
    load(outpath); 
else
    % Read and preprocess data
    read_and_preprocess_tnt(data_string, outpath, Nc, Necho, Nro, Nbuffer, N2d, PRIMARY_COIL_NUMBER);
end