
projectdata = './Projects/editor_tf_fits/Data';
exp_name = '2Dsequence_2Dtable_calibration_singleecho_trigearly_4rx_1repeat_260_gain60_ball_5th_trial2'; 
%exp_name = 'builtin_averages';
outpath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);

SLICE_2 = 20; 
SLICE_3 = 1; 

cd = load(outpath);
coil_data = cd.datafft_combined; 
mr_sequence = coil_data(:, :, :, :, 2); 
mr_plane = squeeze(mr_sequence(:, SLICE_2, SLICE_3, :)); 

NUM_DETECTORS = 4;
size(mr_plane)


figure('color',[1 1 1])
%tlim=[min(d1(1,1),d2(1,1)) max(d1(end,1),d2(end,1))];

titles = {'primary', 'emi1', 'emi2', 'emi3'};

for i = 1:NUM_DETECTORS
    subplot(2,2,i);
    wt(abs(mr_plane(:, i)));
    title(titles{i});
    %set(gca,'xlim',tlim);
end