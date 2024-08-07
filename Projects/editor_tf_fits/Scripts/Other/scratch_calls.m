% Project-specific script to process data using the common editer_algorithm

% Define the path to the dataset
projectdata = './Projects/editor_tf_fits/Data';
%projectdata = './Projects/editor_tf_fits/Data/Raw';
dataFilePath = fullfile(projectdata, 'Raw/JingtingLab/8598/data_EMI_8598.mat');
%dataFilePath = fullfile(projectdata, 'Raw/sai_data_example.mat');
dataFilePath = fullfile(projectdata, 'Processed/Cameleon/v2johnflynn8629.mat');

dataFilePath = fullfile(projectdata, 'Raw/July2-24_flashdrive/July2-24/zgrad_30gain_4coil_1avg_run1.tnt');

coil_data = load(dataFilePath);
coil_data
%%

% Call the common algorithm function
Format_MatFile_For_Editor(dataFilePath, 'ksp_phantomdata_ch2');


%dataFilePath = fullfile(projectdata, 'Processed/tnt','tnt_preprocessed_data_FORMATTED.mat');
%augment_matfile_with_combined(dataFilePath);

%%


diary off;  % Turn off any existing diary
logfile = 'my_log.txt';
if exist(logfile, 'file')
    delete(logfile);  % Delete the existing log file
end
diary(logfile)  % Start a new diary session

% Your code here
dataFilePath = fullfile(projectdata, 'Processed/sai_data_example_3d.mat');
dataFilePath = fullfile(projectdata, 'Processed/data_EMI_8598_FORMATTED.mat');
augment_matfile_with_combined(dataFilePath);
%dataFilePath = fullfile(projectdata, 'Processed/tnt','tnt_preprocessed_data_FORMATTED.mat');

data = load(dataFilePath);
disp(size(data.datafft_combined))



plot_emi_mitigation(data.datafft_combined, 1)

diary off  % End the diary session


%real_data = data.datafft_combined(:, :, :); 
real_data = squeeze(data.datafft_combined(:, :, 1, :)); 
size(real_data)
%Editer_1d_transform(real_data);

%EDITER_1emicoil_func()

%dataFilePath = fullfile(projectdata, 'Processed/tnt','tnt_preprocessed_data_FORMATTED.mat');
%augment_matfile_with_combined(dataFilePath);
%% creating a new cameleon
% first run the process cameleon 

projectdata = './Projects/editor_tf_fits/Data';

CAMELEON_NUMBER = 8598;
camstr = string(CAMELEON_NUMBER); 
suff = strcat('Processed/Cameleon/', camstr, '_FORMATTED.mat'); 
disp(suff)

dataFilePath = fullfile(projectdata, suff);
disp(dataFilePath)
bump_to_3d(dataFilePath);

dataFilePath = fullfile(projectdata, strcat('Processed/Cameleon/', camstr, '_FORMATTED_3d.mat'));
augment_matfile_with_combined(dataFilePath);

%% call editer_1d
projectdata = './Projects/editor_tf_fits/Data';
dataFilePath = fullfile(projectdata, 'Processed/sai_data_example_3d.mat');
dataFilePath = fullfile(projectdata, 'Processed/Cameleon/8598_FORMATTED_3d.mat');
%dataFilePath = fullfile(projectdata, 'Processed/tnt','tnt_preprocessed_data_FORMATTED.mat');
dataFilePath = fullfile(projectdata, 'Processed/homogenous_scanner/bluestoneFirst.mat');

data = load(dataFilePath);
slice_of_data = squeeze(data.datafft_combined(:, :, 12, :)); 
Editer_2d_transform(slice_of_data, true);
%%
combined_data = data.datafft_combined; 
plot_emi_mitigation_slider(combined_data, 1, true, 0);
plot_emi_mitigation_slider(combined_data, 1, true, .25);
plot_emi_mitigation_slider(combined_data, 1, true, .5);
plot_emi_mitigation_slider(combined_data, 1, true, 1);
%plot_emi_mitigation_slider(combined_data, 1, true, 10);
plot_emi_mitigation_slider(combined_data, 1, true, 100);
%plot_emi_mitigation_slider(combined_data, 1, true, 1000);
plot_emi_mitigation_slider(combined_data, 1, true, 10000);
%%
plot_emi_mitigation_slider(combined_data, 1, true, .75);
plot_emi_mitigation_slider(combined_data, 1, true, 1);
plot_emi_mitigation_slider(combined_data, 1, true, 2);
%plot_emi_mitigation(combined_data, 1, true, 3);
plot_emi_mitigation_slider(combined_data, 1, true, 10);
plot_emi_mitigation_slider(combined_data, 1, true, 100);

%% call sai_editor
dataFilePath = fullfile(projectdata, 'Processed/Cameleon/8598_FORMATTED.mat');
Editer_Algorithm_Sai(dataFilePath);


%% bm4d exploration (working well)

% Clear the specific function
clear plot_with_scale

% Clear all functions from memory
clear functions

% Rehash the toolbox cache
rehash

% Check the path to ensure the correct function is being used
which plot_with_scale

close all; 


% VARIABLES
num_points = 10;
sigma_min = 0.01;
sigma_max = .8;
sigma_guesses = linspace(sigma_min, sigma_max, num_points);
scale_factor = 10; 
square_images = true; 
SLICE = 1; 


% Read a grayscale noise-free image and corrupt ourselves
imagepathclean = fullfile(projectdata, 'Raw/images/cameraman256.png');
y = im2double(imread(imagepathclean));
sigma = 0.3;
z = y + sigma * randn(size(y));



% this section if we are using a precorrupted image 
exp_name = 'zgrad_40gain_4coil_4avg_run1';
%dataFilePath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);
dataFilePath = fullfile(projectdata, 'Processed/Cameleon/8598_FORMATTED_3d.mat');
%dataFilePath = fullfile(projectdata, 'Processed/homogenous_scanner/bluestoneFirst.mat');
%dataFilePath = fullfile(projectdata, 'Processed/sai_data_example_3d.mat');
data = load(dataFilePath);
cd = squeeze(data.datafft_combined(:, :, SLICE, 1)); 
z = abs(cd); 
y = z; 

% now adding in the ifft
primary = data.datafft_combined(:, :, :, 1);
img = do_3d_ifft(primary, 'cartesian');  
z = abs(img(:, :, SLICE)); 


% now adding in the editer as a reference
combined_data = squeeze(data.datafft_combined(:, :, SLICE, :)); 
[corrected_img, corrected_ksp] = Editer_2d_transform(combined_data);
y = abs(corrected_img); 
size(y)




% computing and figures 

% Precompute denoised images
y_est_all = cell(1, num_points);
for i = 1:num_points
    y_est_all{i} = BM3D(z, sigma_guesses(i));
end

% Create a figure with subplots for original, corrupted, and denoised images
hFig = figure('Name', 'Denoising with BM3D and Adjustable Sigma', 'NumberTitle', 'off');

subplot(1, 3, 1);
plot_with_scale(y, 'Editer Corrected', square_images, scale_factor);

subplot(1, 3, 2);
plot_with_scale(z, 'Corrupted Image', square_images, scale_factor);

subplot(1, 3, 3);
plot_with_scale(y_est_all{1}, ['Denoised Image (\sigma_{guess} = ', num2str(sigma_guesses(1)), ')'], square_images, scale_factor);

% Create a slider for sigma_guess
uicontrol('Style', 'text', 'String', 'Sigma Guess', 'Position', [20 20 80 20]);
hSlider = uicontrol('Style', 'slider', 'Min', 1, 'Max', num_points, 'Value', 1, ...
                    'Position', [100 20 300 20], 'SliderStep', [1/(num_points-1) , 1/(num_points-1)], ...
                    'Callback', @(src, event) updateDenoisedImage(src, y_est_all, sigma_guesses, subplot(1, 3, 3), square_images, scale_factor));

% Plot all the denoised images next to one another
figure('Name', 'Denoised Images for Different Sigma Values', 'NumberTitle', 'off');
for i = 1:num_points
    subplot(2, ceil(num_points / 2), i);
    title_text = strcat('\sigma_{guess} = ', num2str(sigma_guesses(i)));
    plot_with_scale(y_est_all{i}, title_text, square_images, scale_factor);
end

% Update the denoised image based on the slider value
%function updateDenoisedImage(src, y_est_all, sigma_guesses, hDenoised, square_images, scale_factor)
%    index = round(get(src, 'Value'));
%    y_est = y_est_all{index};
%    subplot(hDenoised);
%    plot_with_scale(y_est, ['Denoised Image (\sigma_{guess} = ', num2str(sigma_guesses(index)), ')'], square_images, scale_factor);
%end


%% BM3D combining with Editer
close all;

% VARIABLES
num_points = 10;
sigma_min = 0.01;
sigma_max = 0.1;
sigma_guesses = linspace(sigma_min, sigma_max, num_points);
scale_factor = .2;
square_images = true;
SLICE = 1;
NUM_AVERAGES = 8; 

% This section if we are using a precorrupted image 
exp_name = 'fulldataset_CCmode_noFilter_halbachcylinder_paperphantom_4Rx_singlegpa65_8avg_run1'; %'zgrad_40gain_4coil_4avg_run1';
dataFilePath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);
%dataFilePath = fullfile(projectdata, 'Processed/Cameleon/8598_FORMATTED_3d.mat');
%dataFilePath = fullfile(projectdata, 'Processed/homogenous_scanner/bluestoneFirst.mat');
%dataFilePath = fullfile(projectdata, 'Processed/sai_data_example_3d.mat');
data = load(dataFilePath);
combined_data = data.datafft_combined / NUM_AVERAGES; 
cd = squeeze(combined_data(:, :, SLICE, 1)); 
z = abs(cd); 
y = z; 

% Now adding in the ifft
primary = combined_data(:, :, :, 1);
img = do_3d_ifft(primary, 'cartesian');  
z = abs(img(:, :, SLICE)); 

% Now adding in the Editer as a reference
combined_data = squeeze(combined_data(:, :, SLICE, :)); 
[corrected_img, corrected_ksp] = Editer_2d_transform(combined_data);
y = abs(corrected_img); 

% Computing and figures 

% Precompute denoised images
y_est_all = cell(1, num_points);
y_est_edit_all = cell(1, num_points);
for i = 1:num_points
    y_est_all{i} = BM3D(z, sigma_guesses(i));
    y_est_edit_all{i} = BM3D(y, sigma_guesses(i)); % Denoised Editer corrected image
end

% Create a figure with subplots for corrupted, Editer corrected, BM3D denoised, and Editer + BM3D denoised images
hFig = figure('Name', 'Denoising with BM3D and Adjustable Sigma', 'NumberTitle', 'off');

subplot(2, 2, 1);
plot_with_scale(z, 'Corrupted Image', square_images, scale_factor);

subplot(2, 2, 2);
plot_with_scale(y, 'Editer Corrected', square_images, scale_factor);

subplot(2, 2, 3);
plot_with_scale(y_est_all{1}, ['BM3D Denoised (\sigma_{guess} = ', num2str(sigma_guesses(1)), ')'], square_images, scale_factor);

subplot(2, 2, 4);

plot_with_scale(y_est_edit_all{1}, ['Editer + BM3D (\sigma_{guess} = ', num2str(sigma_guesses(1)), ')'], square_images, scale_factor);

% Create a slider for sigma_guess
uicontrol('Style', 'text', 'String', 'Sigma Guess', 'Position', [20 20 80 20]);
hSlider = uicontrol('Style', 'slider', 'Min', 1, 'Max', num_points, 'Value', 1, ...
                    'Position', [100 20 300 20], 'SliderStep', [1/(num_points-1) , 1/(num_points-1)], ...
                    'Callback', @(src, event) updateDenoisedImages(src, y_est_all, y_est_edit_all, sigma_guesses, square_images, scale_factor));

% Update the denoised images based on the slider value
%function updateDenoisedImages(src, y_est_all, y_est_edit_all, sigma_guesses, square_images, scale_factor)
%    index = round(get(src, 'Value'));
%    y_est = y_est_all{index};
%    y_est_edit = y_est_edit_all{index};
%    
%    subplot(2, 2, 3);
%    plot_with_scale(y_est, ['BM3D Denoised (\sigma_{guess} = ', num2str(sigma_guesses(index)), ')'], square_images, scale_factor);
%    
%    subplot(2, 2, 4);
%    plot_with_scale(y_est_edit, ['Editer + BM3D (\sigma_{guess} = ', num2str(sigma_guesses(index)), ')'], square_images, scale_factor);
%end

%% BM3D combining with Editer and k-space processing
close all;

% VARIABLES
num_points = 5;
sigma_min = 0.01;
sigma_max = 0.5;
sigma_guesses = linspace(sigma_min, sigma_max, num_points);
scale_factor = 10;
square_images = true;
SLICE = 1;

% Load data
exp_name = 'zgrad_40gain_4coil_4avg_run1';
dataFilePath = fullfile(projectdata, 'Processed/tnt',['tnt_preprocessed_data_', exp_name, '_FORMATTED.mat']);
%dataFilePath = fullfile(projectdata, 'Processed/Cameleon/8598_FORMATTED_3d.mat');
%dataFilePath = fullfile(projectdata, 'Processed/homogenous_scanner/bluestoneFirst.mat');
%dataFilePath = fullfile(projectdata, 'Processed/sai_data_example_3d.mat');
data = load(dataFilePath);
combined_data = data.datafft_combined
cd = squeeze(combined_data(:, :, SLICE, 1)); 
z = abs(cd); 
y = z; 

% Now adding in the ifft
primary = combined_data(:, :, :, 1);
img = do_3d_ifft(primary, 'cartesian');  
z = abs(img(:, :, SLICE)); 

% Now adding in the Editer as a reference
combined_data = squeeze(combined_data(:, :, SLICE, :)); 
[corrected_img, corrected_ksp] = Editer_2d_transform(combined_data);
y = abs(corrected_img); 

% Compute BM3D on the corrupted image
y_est_all = cell(1, num_points);
y_est_edit_all = cell(1, num_points);
for i = 1:num_points
    y_est_all{i} = BM3D(z, sigma_guesses(i));
    y_est_edit_all{i} = BM3D(y, sigma_guesses(i)); % Denoised Editer corrected image
end

% Compute BM3D on k-space data then inverse transform
bm3d_kspace_all = cell(1, num_points);
bm3d_kspace_editer_all = cell(1, num_points);
editer_bm3d_kspace_all = cell(1, num_points);
for n = 1:num_points
    disp(n)
    
    post_bm3d_kspace_combined = zeros(size(combined_data));
    for coil = 1:size(combined_data, 3)
        coil_bm3d_kspace_real = BM3D(real(combined_data(:, :, coil)), sigma_guesses(n));
        coil_bm3d_kspace_imag = BM3D(imag(combined_data(:, :, coil)), sigma_guesses(n));
        post_bm3d_kspace_combined(:, :, coil) = coil_bm3d_kspace_real + 1i * coil_bm3d_kspace_imag;
    end

    bm3d_kspace_img = ifftshift(ifft2(ifftshift(post_bm3d_kspace_combined(:,:,1))));
    bm3d_kspace_all{n} = abs(bm3d_kspace_img);
    %size(post_bm3d_kspace_combined)
    %[bm3d_kspace_editer_img, notused] = Editer_2d_transform(post_bm3d_kspace_combined, 'check');
    %bm3d_kspace_editer_all{i} = abs(bm3d_kspace_editer_img);
end    
%    editer_ksp = Editer_2d_transform(primary);
%    editer_bm3d_kspace = BM3D(editer_ksp, sigma_guesses(i));
%    editer_bm3d_kspace_img = do_3d_ifft(editer_bm3d_kspace, 'cartesian');
%    editer_bm3d_kspace_all{i} = abs(editer_bm3d_kspace_img(:, :, SLICE));
%end

% Create a figure with subplots for all the images
hFig = figure('Name', 'Denoising with BM3D and Adjustable Sigma', 'NumberTitle', 'off');

subplot(2, 4, 1);
plot_with_scale(z, 'Corrupted Image', square_images, scale_factor);

subplot(2, 4, 2);
plot_with_scale(y, 'Editer Corrected', square_images, scale_factor);

subplot(2, 4, 3);
plot_with_scale(y_est_all{1}, ['BM3D Denoised (\sigma_{guess} = ', num2str(sigma_guesses(1)), ')'], square_images, scale_factor);

subplot(2, 4, 4);
plot_with_scale(y_est_edit_all{1}, ['Editer + BM3D (\sigma_{guess} = ', num2str(sigma_guesses(1)), ')'], square_images, scale_factor);

subplot(2, 4, 5);
plot_with_scale(bm3d_kspace_all{1}, ['BM3D on k-space (\sigma_{guess} = ', num2str(sigma_guesses(1)), ')'], square_images, scale_factor);

%subplot(2, 4, 6);
%plot_with_scale(bm3d_kspace_editer_all{1}, ['BM3D k-space -> Editer (\sigma_{guess} = ', num2str(sigma_guesses(1)), ')'], square_images, scale_factor);

%subplot(2, 4, 7);
%plot_with_scale(editer_bm3d_kspace_all{1}, ['Editer -> BM3D k-space (\sigma_{guess} = ', num2str(sigma_guesses(1)), ')'], square_images, scale_factor);

% Create a slider for sigma_guess for image domain
uicontrol('Style', 'text', 'String', 'Sigma Guess (Image)', 'Position', [20 20 150 20]);
hSliderImage = uicontrol('Style', 'slider', 'Min', 1, 'Max', num_points, 'Value', 1, ...
                         'Position', [170 20 300 20], 'SliderStep', [1/(num_points-1) , 1/(num_points-1)], ...
                         'Callback', @(src, event) updateImageDomain(src, y_est_all, y_est_edit_all, bm3d_kspace_all, sigma_guesses, square_images, scale_factor));

% Create a figure for k-space visualization
hFig2 = figure('Name', 'K-space Visualization with BM3D and Adjustable Sigma', 'NumberTitle', 'off');

subplot(1, 3, 1);
plot_with_scale(abs(cd), 'Original k-space', square_images, scale_factor);

subplot(1, 3, 2);
plot_with_scale(abs(post_bm3d_kspace_combined(:,:,1)), ['BM3D k-space (\sigma_{guess} = ', num2str(sigma_guesses(1)), ')'], square_images, scale_factor);

% Create a slider for sigma_guess for k-space domain
uicontrol(hFig2, 'Style', 'text', 'String', 'Sigma Guess (K-space)', 'Position', [20 20 150 20]);
hSliderKspace = uicontrol(hFig2, 'Style', 'slider', 'Min', 1, 'Max', num_points, 'Value', 1, ...
                          'Position', [170 20 300 20], 'SliderStep', [1/(num_points-1) , 1/(num_points-1)], ...
                          'Callback', @(src, event) updateKspaceDomain(src, bm3d_kspace_all, sigma_guesses, square_images, scale_factor));

% Update the image domain based on the slider value
function updateImageDomain(src, y_est_all, y_est_edit_all, bm3d_kspace_all, sigma_guesses, square_images, scale_factor)
    index = round(get(src, 'Value'));
    y_est = y_est_all{index};
    y_est_edit = y_est_edit_all{index};
    bm3d_kspace_img = bm3d_kspace_all{index};
    
    figure(hFig);
    subplot(2, 4, 3);
    plot_with_scale(y_est, ['BM3D Denoised (\sigma_{guess} = ', num2str(sigma_guesses(index)), ')'], square_images, scale_factor);
    
    subplot(2, 4, 4);
    plot_with_scale(y_est_edit, ['Editer + BM3D (\sigma_{guess} = ', num2str(sigma_guesses(index)), ')'], square_images, scale_factor);
    
    subplot(2, 4, 5);
    plot_with_scale(bm3d_kspace_img, ['BM3D on k-space (\sigma_{guess} = ', num2str(sigma_guesses(index)), ')'], square_images, scale_factor);
end

% Update the k-space domain based on the slider value
function updateKspaceDomain(src, bm3d_kspace_all, sigma_guesses, square_images, scale_factor)
    index = round(get(src, 'Value'));
    bm3d_kspace_img = bm3d_kspace_all{index};
    
    figure(hFig2);
    subplot(1, 3, 2);
    plot_with_scale(abs(bm3d_kspace_img), ['BM3D k-space (\sigma_{guess} = ', num2str(sigma_guesses(index)), ')'], square_images, scale_factor);
end

%%
function updateDenoisedImages(src, y_est_all, y_est_edit_all, sigma_guesses, square_images, scale_factor)
    index = round(get(src, 'Value'));
    y_est = y_est_all{index};
    y_est_edit = y_est_edit_all{index};
    
    subplot(2, 2, 3);
    plot_with_scale(y_est, ['BM3D Denoised (\sigma_{guess} = ', num2str(sigma_guesses(index)), ')'], square_images, scale_factor);
    
    subplot(2, 2, 4);
    plot_with_scale(y_est_edit, ['Editer + BM3D (\sigma_{guess} = ', num2str(sigma_guesses(index)), ')'], square_images, scale_factor);
end