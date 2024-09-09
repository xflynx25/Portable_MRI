clear all;
clf; 



% data_string = 'E:\DATA_bluestone\20240411\noise_ACQUIRE_POWER_BOX_run10.tnt';
%data_string = 'C:\Users\Public\fulldataset_CVmode_halbachcylinder_activeTR_1Rx_singlegpatest_run5.tnt';
%data_string = 'C:\Users\Public\Data\20240710\fulldataset_CVmode_halbachcylinder_4Rx_singlegpa40_1avg_run2.tnt';
%data_string = 'C:\Users\Public\Data\20240710\fulldataset_CCmode_noFilter_halbachcylinder_4Rx_singlegpa50_1avg_run1.tnt';
%data_string = 'C:\Users\Public\Data\20240710\fulldataset_CCmode_noFilter_halbachcylinder_spherephantom_4Rx_singlegpa50_1avg_run1.tnt';
%data_string = 'Raw/20240710/fulldataset_CCmode_noFilter_halbachcylinder_paperphantom_4Rx_singlegpa65_8avg_run1.tnt';
data_string = 'Raw/20240710/fulldataset_CCmode_noFilter_halbachcylinder_paperphantom_1Rx_singlegpa65_4avg_run1.tnt';
%data_string = 'Raw/July2-24_flashdrive/July2-24/zgrad_40gain_4coil_1avg_run1.tnt';
data_string = 'Raw/John_tnt_data/cylinder_test_activeTR_2Rx_datasorted.tnt';

projectdata = './Projects/editor_tf_fits/Data';
dataFilePath = fullfile(projectdata, data_string);

%dataFilePath = 'C:\Users\Public\Data\20240727\fulldataset_CC_gain40_1Rx_singlegpa_emioff_run2_connectedoscilloscope.tnt';
%dataFilePath = 'C:\Users\Public\Data\20240711\CCmode_noFilter_4Rx_test.tnt';
%dataFilePath = 'C:\Users\Public\Data\20240727\spherephantom_fulldataset_CC_gain65_4avg_1Rx_singlegpa_emioff_gradpad130_run1.tnt';
%dataFilePath = 'C:\Users\Public\Data\20240728\tester.tnt';

[ Ms1, Header, Var_data ] = Read_Tecmag(dataFilePath);
Nc = 1; 
Necho = 30;
Nro  = 256;
plot_kspace = 0;
SLICE = 11; 

Ms_reorder_pos = tntreshape(Ms1, Nro, Necho*Nc);
temp = permute(Ms_reorder_pos,[2,3,1]);
% temp2 =  temp(:,:,1:30);


%coil1 = temp(:,2:end,1:Necho);
coil1 = temp(:,2:end,1:Necho);

if Nc == 1
    coil2 = coil1; 
    coil3 = coil1; 
    coil4 = coil1; 
else 
    if Nc == 2
        coil2 = temp(:,2:end,Necho+1:Necho*2);
        coil3 = coil1; 
        coil4 = coil1; 
    
    else
        %coil2 = temp(:,2:end,Necho+1:Necho*2);
        %coil3 = temp(:,2:end,Necho*2+1:Necho*3);
        %coil4 = temp(:,2:end,Necho*3+1:Necho*4);
        
        coil2 = temp(:,:,Necho+1:Necho*2);
        coil3 = temp(:,:,Necho*2+1:Necho*3);
        coil4 = temp(:,:,Necho*3+1:Necho*4);
    end
end

% CALCULATING THE ZEROS
Kcoil1 = ((( coil1(:,:,SLICE))));
Kcoil2 = ((( coil2(:,:,SLICE))));
Kcoil3 = ((( coil3(:,:,SLICE))));
Kcoil4 = ((( coil4(:,:,SLICE))));

abs(sum(Kcoil4, 2))

Kcoils = {Kcoil1, Kcoil2, Kcoil3, Kcoil4};
for num = 1:Nc
    
    result = abs(sum(Kcoils{num}, 2));
    % Step 2: Find the indices where the result is zero
    zero_indices = find(result == 0);
    
    % Step 3: Print out those indices
    fprintf('Indices where coil in coil%d is zero:\n', num);
    disp(zero_indices);
end

% PLOTTING EITHER THE IFFT OR THE KSPACE

% data = temp2(:,2:end,:);
data_1 = coil1(:,:,SLICE);

Icoil1 = ifftshift(ifft2(ifftshift( coil1(:,:,SLICE))));
Icoil2 = ifftshift(ifft2(ifftshift( coil2(:,:,SLICE))));
Icoil3 = ifftshift(ifft2(ifftshift( coil3(:,:,SLICE))));
Icoil4 = ifftshift(ifft2(ifftshift( coil4(:,:,SLICE))));

%trying 3d
%Icoil1 = ifftshift(ifftn(ifftshift( coil1)));
%Icoil1 = Icoil1(:, :, SLICE); 

scale1 = [0,.25];
scale2 = [0,.5];
 
if plot_kspace == 1
    maxval = abs(max(max(coil1(:,:,SLICE)))); 
    maxval
    scale1 = [0,maxval/16];
    scale2 = [0,maxval/8];
    Icoil1 = ((( coil1(:,:,SLICE))));
    Icoil2 = ((( coil2(:,:,SLICE))));
    Icoil3 = ((( coil3(:,:,SLICE))));
    Icoil4 = ((( coil4(:,:,SLICE))));
end


figure; imagesc(abs(rot90(Icoil1)));

figure; 
subplot(2,2,1);
imagesc(abs(rot90(Icoil1)));     colormap gray; 
caxis(scale1);
title('primary coil');

subplot(2,2,2);
imagesc(abs(rot90(Icoil2)));  %colorbar;
caxis(scale2);
title('EMI coil 1');

subplot(2,2,3);
imagesc(abs(rot90(Icoil3)));  %colorbar;
% caxis(scale1);
title('EMI coil 2');

subplot(2,2,4);
imagesc(abs(Icoil4));  %colorbar;
% caxis(scale1);
title('EMI coil 3');


fclose('all');