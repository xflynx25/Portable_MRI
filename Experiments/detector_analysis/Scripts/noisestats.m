% get statistics on images for dynamic range investigations

% select an option here 
data_folder = 'CalibrationTrials'; 
experimentName = 'calibration_doubleacq_2avgs_FORMATTED';

data_folder = 'BroadSNRperformance'; 
experimentName = 'with_blanket_newgradON_doubleacquisition_test1_FORMATTED';


if false
    ListFilesInFolder(fullfile(evalin('base', 'customDataDir'), data_folder))
    error('get rekked');
end



% formatting filepaths 
procDataDir = evalin('base', 'customDataDir');
outpath = fullfile(procDataDir, data_folder, [experimentName, '.mat']);%, '_FORMATTED.mat']);
cd = load(outpath).datafft_combined; 


options.visualize = 1;
%options.SLICE = 2;  % Overriding just the SLICE value
options.IMAGE_SCALE = 0;  % Custom image scale
options.KSPACE_SCALE = 1; 
options.CALIBRATION = 0; 




%DefaultVisualization(cd, options);

coil = 1; 
coil_data = cd(:, :, 1, 1, size(cd, 5), coil); 
plottydata = squeeze(cd(:, :, 1, 1, size(cd, 5), :)); 
%plotCoilDataView2D(plottydata, 1, 0)

% Call the function% Coil indices (6th dimension of your data)
% Coil indices (6th dimension of your data)
coil_indices = [1, 2, 3, 4];
num_bins_list = [100, 100, 100, 100, 100, 100, 100, 100]; %[60, 50, 40, 30, 50, 60];  
logscale_list = [true, true, true, true, true, true, true, true];

% Create a 2x3 grid of subplots using tiledlayout for better control over spacing
num_coils = length(coil_indices);
t = tiledlayout(2, num_coils, 'TileSpacing', 'compact', 'Padding', 'compact');


% Loop through coils and plot both the coil and its IFFT
for i = 1:num_coils
    % Extract coil data
    coil_data = cd(:, :, 1, 1, size(cd, 5), coil_indices(i));
    
    % Get the number of bins for the current coil
    num_bins_coil = num_bins_list(i);
    num_bins_ifft = num_bins_list(i + num_coils);  % Assume next bins are for IFFT plots
    
    % Plot the histogram for the coil data
    nexttile(i);  % Select the i-th tile in the 2x3 grid
    plot_matrix_histogram(abs(coil_data), num_bins_coil, logscale_list(i));  % Disable logscale by default
    title(sprintf('Coil %d (k-space)', coil_indices(i)));
    
    % Plot the histogram for the IFFT of the coil data
    nexttile(i + num_coils);  % Select the tile in the lower row
    plot_matrix_histogram(abs(shiftyifft(coil_data)), num_bins_ifft, logscale_list(i+num_coils));
    title(sprintf('IFFT Coil %d', coil_indices(i)));
end

% Adjust figure size
set(gcf, 'Position', [100, 100, 1200, 800]);  % Adjust figure size


%plot_matrix_histogram(abs(cd1), num_bins, true);
%plot_matrix_histogram(abs(cd2), num_bins, true);
%plot_matrix_histogram(abs(cd4), num_bins, true);
%plot_matrix_histogram(abs(shiftyifft(cd1)), num_bins,true);
%plot_matrix_histogram(abs(shiftyifft(cd2)), num_bins,true);
%plot_matrix_histogram(abs(shiftyifft(cd4)), num_bins, true);
throw('boom')


% Now select 3 regions of the image 
roi_data = get_polygonroi_data(shiftyifft(coil_data));  % Use the helper function to get ROI data
stats = matrix_statistics(abs(roi_data));
pde = (stats.std / stats.mean) * 100;
size(roi_data) 
fprintf('Mean: %.2f\n', stats.mean);
fprintf('Percent Deviation Error: %.2f%%\n', pde);

% Now select 3 regions of the image 
roi_data = get_polygonroi_data(shiftyifft(coil_data));  % Use the helper function to get ROI data
stats = matrix_statistics(abs(roi_data));
pde = (stats.std / stats.mean) * 100;
size(roi_data) 
fprintf('Mean: %.2f\n', stats.mean);
fprintf('Percent Deviation Error: %.2f%%\n', pde);

% Now select 3 regions of the image 
roi_data = get_polygonroi_data(shiftyifft(coil_data));  % Use the helper function to get ROI data
stats = matrix_statistics(abs(roi_data));
pde = (stats.std / stats.mean) * 100;
size(roi_data) 
fprintf('Mean: %.2f\n', stats.mean);
fprintf('Percent Deviation Error: %.2f%%\n', pde);