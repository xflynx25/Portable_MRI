

% select an option here 
data_folder = 'BroadSNRperformance'; 
experimentName = '8716_FORMATTED';


if true
    ListFilesInFolder(fullfile(evalin('base', 'customDataDir'), data_folder))
    %ListFilesInFolder(fullfile(evalin('base', 'procDataDir'), data_folder))
    
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




DefaultVisualization(cd, options);

% for averages ... 
%N = 6; 
%avgcd = squeeze(cd(:, :, 1, 1, 1:N, 1));
%plotCoilDataView2D(avgcd, 2, 1)