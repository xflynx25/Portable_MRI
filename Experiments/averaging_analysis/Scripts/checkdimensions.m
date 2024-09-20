

data_folder = '80mT_Scanner/20240823'; 
experimentName = 'brain_calibration_repeat2D_newgradON_trial1_FORMATTED';
Datadir = evalin('base', 'procDataDir');

ListFilesInFolder(fullfile(Datadir, data_folder))

pd = load(fullfile(Datadir, data_folder, [experimentName, '.mat'])).datafft_combined; %processed data
size(pd)