clear all;


% data_string = 'E:\DATA_bluestone\20240411\noise_ACQUIRE_POWER_BOX_run10.tnt';
% data_string = 'C:\Users\Public\fulldataset_CVmode_halbachcylinder_activeTR_1Rx_singlegpatest_run5.tnt';
data_string = 'Raw/20240710/fulldataset_CCmode_noFilter_halbachcylinder_paperphantom_4Rx_singlegpa65_8avg_run1.tnt';

projectdata = './Projects/editor_tf_fits/Data';
dataFilePath = fullfile(projectdata, data_string);


[ Ms1, Header, Var_data ] = Read_Tecmag(dataFilePath);
Nc = 4; 
Necho = 30;
Nro  = 256;

Ms_reorder_pos = tntreshape(Ms1, Nro, Necho*Nc);
temp = permute(Ms_reorder_pos,[2,3,1]);

% temp2 =  temp(:,:,1:30);
coil1 = temp(:,2:end,1:Necho);
coil2 = temp(:,2:end,Necho+1:Necho*2);
coil3 = temp(:,2:end,Necho*2+1:Necho*3);
coil4 = temp(:,2:end,Necho*3+1:Necho*4);


% data = temp2(:,2:end,:);
data_1 = coil4(:,:,1);

Icoil1 = ifftshift(ifft2(ifftshift( coil1(:,:,1))));
Icoil2 = ifftshift(ifft2(ifftshift( coil2(:,:,1))));
Icoil3 = ifftshift(ifft2(ifftshift( coil3(:,:,1))));
Icoil4 = ifftshift(ifft2(ifftshift( coil4(:,:,1))));

figure; imagesc(abs(rot90(Icoil1)));
scale1 = [0,max(max(abs(Icoil1)))]; %colors with respect to the max in the primary 
colorbar;

figure; 
subplot(2,2,1);
imagesc(abs(rot90(Icoil1))); colorbar;
caxis(scale1);
title('primary coil');

subplot(2,2,2);
imagesc(abs(rot90(Icoil2)));  colorbar;
caxis(scale1);
title('EMI coil 1');

subplot(2,2,3);
imagesc(abs(rot90(Icoil3)));  colorbar;
caxis(scale1);
title('EMI coil 2');

subplot(2,2,4);
imagesc(abs(rot90(Icoil4)));  colorbar;
caxis(scale1);
title('EMI coil 3');


fclose('all');