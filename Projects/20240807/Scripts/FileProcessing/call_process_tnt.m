clear all;

% File paths and parameters
projectdata = './Projects/20240807/Data';

exp_name = 'averaging_4avgs_4repeats';
exp_name = 'calibration_doubleacq_morepoints'; 
exp_name = 'acquire_3d_twoandtwo_calibration_maxxx'; 
data_string = fullfile(projectdata, 'Raw', [exp_name, '.tnt']);
outpath = fullfile(projectdata, 'Processed/tnt/',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);



% Parameters
PRIMARY_COIL_NUMBER = 1; 
Nc = 4; % Number of coils
Necho = 30; % Number of echoes per coil
Nro = 256; % Number of readout points 
Navg = 1; %repetitions in 2D, adjacent in time
Ncalib = 2; 
N2d = Navg * Ncalib;
Nbuffer = 0;
Nfe = 51; %number of echo train sequences, this # + 1 should be divisible into the last index
Nrepeats = 2; % repetitions in 4d, of whole experiment


% Check if preprocessed data exists so don't do many times
if exist(outpath, 'file') && false
    load(outpath); 
else
    % Read and preprocess data
    new_preprocesstnt(data_string, outpath, Nc, Necho, Nro, Nbuffer, N2d, Nrepeats, Nfe, PRIMARY_COIL_NUMBER);
end