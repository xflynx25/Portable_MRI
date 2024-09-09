% Project-specific script to process data using the common editer_algorithm

% Define the path to the dataset
projectdata = './Projects/editor_tf_fits/Data';
%projectdata = './Projects/editor_tf_fits/Data/Raw';
dataFilePath = fullfile(projectdata, 'Processed/data_EMI_8598_FORMATTED.mat');
%dataFilePath = fullfile(projectdata, 'Processed/sai_data_example.mat');

%dataFilePath = fullfile(projectdata, 'Processed/tnt/tnt_preprocessed_data_FORMATTED.mat');

exp_name = 'fulldataset_CCmode_noFilter_halbachcylinder_paperphantom_4Rx_singlegpa65_8avg_run1'; %'zgrad_40gain_4coil_4avg_run1';
dataFilePath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);



% Call the common algorithm function
%data = load(dataFilePath);
Editer_Algorithm_Sai(dataFilePath);


