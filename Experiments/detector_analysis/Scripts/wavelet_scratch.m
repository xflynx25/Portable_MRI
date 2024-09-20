
% USER INPUT
scan_selector = 4; 
IMAGE_SCALE = 2; 
KSPACE_SCALE = 0; 


% LOADING, PREPARATION
close all; %plots
pd = read_in_common_dataset(scan_selector); 



% FORMATTING
disp('references')
if size(pd, 5) > 1
    cd = squeeze(pd(:, :, 1, 1, 2, :));
else
    cd = squeeze(pd(:, :, 1, 1, 1, :)); % when no calibration
end
plotCoilDataView2D(cd, IMAGE_SCALE, KSPACE_SCALE)
primary_ksp = cd(:, :, 1);
primary_img = shiftyifft(primary_ksp);
num_coils = size(pd, 6); 


SLICE_2 = 20; 
mr_plane = squeeze(cd(:, SLICE_2, :)); 

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