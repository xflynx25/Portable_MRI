clear; close all;

projectdatafolder = './Projects/editor_tf_fits/Data';
%projectdatafolder = './Projects/08242024/8673';
expno = 8699; %8598;


expostring = num2str(expno);
data_path = fullfile(projectdatafolder, 'Raw/jerryComputer/EDITER', expostring);
data_path = fullfile(projectdatafolder, 'Raw/jerryComputer/EDITER/08242024', expostring);
ending = strcat(expostring, '.mat');
outpath = fullfile(projectdatafolder, 'Processed/Cameleon', ending);

%----------------------
%-- Parameters
%----------------------
matrix1d     = 128; %  MATRIX_DIMENSION_1D
matrix2d     = 128; % MATRIX_DIMENSION_2D
matrix3d     = 1; % MATRIX_DIMENSION_3D
matrix4d     = 1; % MATRIX_DIMENSION_4D
ncoils  = 4; % RECEIVER_COUNT 
PRIMARY_COIL_NUMBER = 2; 
PLOT_PRIMARY = true; 
% if we are looping from autotrials, we could infer either matrix1d or
% ncoils depending on what is being kept constant

%----------------------
%-- Read Data
%----------------------
dataFile = [data_path '/data.dat'];    

dataFile
   
file = fopen(dataFile);
data = fread(file, 'float32','b'); 
size(data)
128 * 128 * 4
fclose(file);

% Automatically calculate the number of coils
total_elements = numel(data);
element_per_coil = 2 * matrix1d * matrix2d * matrix3d * matrix4d; % factor of 2 for real and imaginary parts
ncoils = total_elements / element_per_coil;
ksp = zeros(matrix1d,matrix2d,ncoils);

% Validate the number of coils
if rem(ncoils, 1) ~= 0
    error('The total number of elements does not match the expected size for the given dimensions.');
end

%
data = reshape(data, 2, matrix1d , matrix2d , matrix3d , matrix4d , ncoils); 
data = complex(data(2,:,:,:,:,:), data(1,:,:,:,:,:));   
z = size(data); 
for nc = 1:ncoils
    ksp(:,:,nc)= reshape(data(:,:,:,nc),z(2:end-1)); % 1x256x256 complex
end

% Calculate the grid size for the given number of coils
rows = ceil(sqrt(ncoils));
cols = ceil(ncoils / rows);

sw = 20032.05128205128; % Hz
np = matrix1d;
freq = -sw/2:sw/np:(sw/2-sw/np);

%% plot ksp and img for all 

%----------------------
%-- Plot K-space for All Coils
%----------------------
figure('Name', 'K-space for All Coils');
tiledlayout(rows, cols, 'TileSpacing', 'Compact', 'Padding', 'Compact'); % Dynamic grid

for nc = 1:ncoils
    ksp_plot = ksp(:, :, nc);
    nexttile;
    pcolor(freq, freq, abs(ksp_plot')), shading interp; colormap('gray');
    xlabel('k_x (Hz)', 'FontSize', 14);
    ylabel('k_y (Hz)', 'FontSize', 14);
    title(['ksp - Coil ', num2str(nc)]);
end

%----------------------
%-- Plot Images for All Coils
%----------------------
FOV = 60; % mm
x_dim = -FOV/2:FOV/(matrix1d-1):FOV/2;
y_dim = x_dim;

figure('Name', 'Images for All Coils');
tiledlayout(rows, cols, 'TileSpacing', 'Compact', 'Padding', 'Compact'); % Dynamic grid

for nc = 1:ncoils
    ksp_plot = ksp(:, :, nc);
    img = transpose(fftshift(fft2(ksp_plot))); % Transpose forces freq to be x axis
    nexttile;
    pcolor(x_dim, y_dim, abs(img)), shading interp; colormap(gray);
    xlabel('x (mm)', 'FontSize', 14);
    ylabel('y (mm)', 'FontSize', 14);
    title(['img - Coil ', num2str(nc)]);
end

%% plot just the primary
if PLOT_PRIMARY
    ksp_plot = ksp(:,:,PRIMARY_COIL_NUMBER);
    FOV = 60; %mm
    x_dim = -FOV/2:FOV/(matrix1d-1):FOV/2;
    y_dim = x_dim;
    
    
    figure('name','ksp');
    pcolor(freq,freq,abs(ksp_plot')), shading interp; colormap('gray')
    xlabel('k_x (Hz)','fontsize', 14)
    ylabel('k_y (Hz)','fontsize', 14)
    title('ksp');
    
    
    img = transpose(fftshift(fft2(ksp_plot))); % transpose forces freq to be x axis
    
    figure('name','img'); pcolor(x_dim,y_dim,abs(img)), shading interp; colormap(gray); 

    xlabel('x (mm)','fontsize', 14)
    ylabel('y (mm)','fontsize', 14)
    title('img');
    
    whos
    ending = strcat('v2johnflynn', expostring, '.mat');
    outpath = fullfile(projectdatafolder, 'Processed/Cameleon', ending);
    %save(outpath,'ksp','img'); %,'fft_phase_encode');
end 

%% new version of saving

vars_to_save = {};%{'img', 'ksp'}; % Initialize with any other variables you want to save

for nc = 1:ncoils
    ksp_single_coil = ksp(:,:,nc);
    varname = sprintf('ksp_noisedata_ch%d', nc);
    eval([varname ' = ksp_single_coil;']); % Dynamically create variable
    vars_to_save{end+1} = varname; % Add the variable name to the list of variables to save
end

% Save all variables to the output file
save(outpath, vars_to_save{:});

% make the names proper
primary_name = sprintf('ksp_noisedata_ch%d', PRIMARY_COIL_NUMBER);
Format_MatFile_For_Editor(outpath, primary_name);

