% This script will try and elucidate the mysteries of editer
% Phase 1: what is being fit? 
% Phase 2: how do they work together (correlation analysis)
% Phase 3: are there any small adjustments that will improve it


projectdata = './Projects/editor_tf_fits/Data';
dataFilePath = fullfile(projectdata, 'Processed/Cameleon/8598_FORMATTED_3d.mat');

exp_name = 'zgrad_40gain_4coil_4avg_run1';
dataFilePath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);

exp_name = 'fulldataset_CCmode_noFilter_halbachcylinder_paperphantom_4Rx_singlegpa65_8avg_run1'; %'zgrad_40gain_4coil_4avg_run1';
dataFilePath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);


data = load(dataFilePath);
cd = squeeze(data.datafft_combined(:, :, 1, :)); 
daspect = 4;
close all; 
Editer_2d_transform(cd, true, daspect); 
%Editer_2d_CorrelationByNumber(cd, true, daspect); 