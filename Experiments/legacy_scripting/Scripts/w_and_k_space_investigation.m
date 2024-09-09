
chosen_folder_name = './Projects/editor_tf_fits/Data';
dataFilePath = fullfile(chosen_folder_name, 'Processed/Cameleon/',['8598', '_FORMATTED.mat']);

data = load(dataFilePath);
cd = data.datafft_combined;
num_dimensions = length(size(cd));
num_coils = size(cd, 3); 
disp(size(data.datafft_combined));
% 128   128     4

% i just want to see the image and the FT of each of these 
% visualizing ksp and image
disp('Plotting initial vis...');
figure;
for i = 1:num_coils
    subplot(2, num_coils, i);
    imgspace = ifftshift(ifft2(ifftshift(cd(:, :, i))));
    plot_with_scale(abs(imgspace), sprintf('Image coil%d', i), true, IMAGE_SCALE);
end 
for i = 1:num_coils 
    subplot(2, num_coils, 4 + i);
    plot_with_scale(abs(cd(:, :, i)), sprintf('ksp coil%d', i), true, KSPACE_SCALE);
end 