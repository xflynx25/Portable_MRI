% transfer matfile format -> csv for ML processing

projectdata = './Projects/editor_tf_fits/Data';
exp_name = '2Dsequence_2Dtable_calibration_singleecho_trigearly_4rx_1repeat_260_gain60_ball_5th_trial2';
outpath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);
csv_output_path = fullfile(projectdata, 'Processed/tntcsv',['tnt_preprocessed_data_', exp_name, '_FORMATTED.csv']);


% calibration files are something like 256x40x2x4x2
% we need to put this into csv

% Load the MAT-file
data = load(outpath);

% Assuming the primary data is stored in a variable called 'datafft_combined'
% Adjust this according to the actual variable name in your MAT-file
if isfield(data, 'datafft_combined')
    data_array = data.datafft_combined;
else
    error('The variable datafft_combined is not found in the MAT-file.');
end

% Get the dimensions of the data
[ncol, nlin, nslc, Nc, n2d] = size(data_array);

% Reshape the data into a 2D array
% Flatten all dimensions except the first two, so that each row represents a single data point
reshaped_data = reshape(data_array, ncol * nlin * nslc * Nc * n2d, []);

% Create a table from the reshaped data
data_table = array2table(reshaped_data);

% Write the table to a CSV file
writetable(data_table, csv_output_path);

disp(['Data has been successfully written to ', csv_output_path]);