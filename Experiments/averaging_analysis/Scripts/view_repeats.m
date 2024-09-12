

% select an option here 
data_folder = 'RepeatMetric'; 
experimentName = 'brain_calibration_repeat2D_FORMATTED';


if false
    ListFilesInFolder(fullfile(evalin('base', 'customDataDir'), data_folder))
    error('get rekked');
end



% formatting filepaths 
procDataDir = evalin('base', 'customDataDir');
outpath = fullfile(procDataDir, data_folder, [experimentName, '.mat']);%, '_FORMATTED.mat']);
cd = load(outpath).datafft_combined; 


IMAGE_SCALE = 5;  % Custom image scale
KSPACE_SCALE = .2; 

cd = slice_dimension(cd, [1,2,4], 6);
calibration = slice_dimension(cd, 1, 5);
mr = slice_dimension(cd, 2, 5);
c1 = squeeze(calibration(:, :, 1, 1, :, :));
c2 = squeeze(calibration(:, :, 1, 2, :, :));
mr1 = squeeze(mr(:, :, 1, 1, :, :));
mr2 = squeeze(mr(:, :, 1, 2, :, :));



plotCoilDataView2D(c1, IMAGE_SCALE, KSPACE_SCALE)
plotCoilDataView2D(c2, IMAGE_SCALE, KSPACE_SCALE)
plotCoilDataView2D(mr1, IMAGE_SCALE, KSPACE_SCALE)
plotCoilDataView2D(mr2, IMAGE_SCALE, KSPACE_SCALE)
set(gca, 'XTickLabel', [], 'YTickLabel', []);
set(gca, 'XTick', [], 'YTick', []);

