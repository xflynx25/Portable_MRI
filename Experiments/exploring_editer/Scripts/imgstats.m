% get statistics on images for dynamic range investigations

% select an option here 
data_folder = 'CalibrationTrials'; 
experimentName = 'calibration_doubleacq_2avgs_FORMATTED';


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

coil = 4; 
coil_data = cd(:, :, 1, 1, size(cd, 5), coil); 
plottydata = squeeze(cd(:, :, 1, 1, size(cd, 5), :)); 
plotCoilDataView2D(plottydata, 1, 0)

% Call the function
statistics = matrix_statistics(real(coil_data));
disp(statistics);
statistics = matrix_statistics(imag(coil_data));
disp(statistics);
statistics = matrix_statistics(abs(coil_data));
disp(statistics);
statistics = matrix_statistics(abs(shiftyifft(coil_data)));
disp(statistics);
