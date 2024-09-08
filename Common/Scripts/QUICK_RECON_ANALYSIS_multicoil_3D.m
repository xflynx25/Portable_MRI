clear all;

addpath(addpath('C:\Users\Public\matlab_basic_functions'));
addpath(addpath('C:\Users\Public\matlab_basic_functions\ReadData\'));

% data_string = 'E:\DATA_bluestone\20240411\noise_ACQUIRE_POWER_BOX_run10.tnt';
%data_string = 'C:\Users\Public\fulldataset_CVmode_halbachcylinder_activeTR_1Rx_singlegpatest_run5.tnt';
data_string = 'C:\Users\Public\Data\20240710\fulldataset_CVmode_halbachcylinder_4Rx_singlegpa40_1avg_run2.tnt';
data_string = 'C:\Users\Public\Data\20240710\fulldataset_CCmode_noFilter_halbachcylinder_4Rx_singlegpa50_1avg_run1.tnt';
data_string = 'C:\Users\Public\Data\20240712\test_Gzon_singleecho_41PE_EMIpreampson_1ave_1rx_65grad_CCmode_trial1.tnt';
data_string = 'C:\Users\Public\Data\20240712\test_Gzon_singleecho_41PE_EMIpreampson_1ave_1rx_65grad_CCmode_trial1.tnt';
data_string = 'C:\Users\Public\Data\20240809\3Dsequence_2Dtable_averaging_echotrain_test1.tnt';
% data_string = 'C:\Users\Public\Data\20240809\3Dsequence_2Dtable_averaging_echotrain_newgradOFF_test1.tnt';
% data_string = 'C:\Users\Public\Data\20240809\3Dsequence_2Dtable_averaging_echotrain_newgradPOWEROFF_test1.tnt';
% data_string = 'C:\Users\Public\Data\20240809\no_blanket_test1.tnt';


[ Ms1, Header, Var_data ] = Read_Tecmag(data_string);
Nc = 4; 
Necho = 21;
Nro  = 256;

size(Ms1)

Ms_reorder_pos = tntreshape(Ms1, Nro, Necho*Nc);
temp = permute(Ms_reorder_pos,[2,3,1]);
% temp2 =  temp(:,:,1:30);
coil1 = temp(:,2:end,1:Necho);
coil2 = temp(:,2:end,Necho+1:Necho*2);
coil3 = temp(:,2:end,Necho*2+1:Necho*3);
coil4 = temp(:,2:end,Necho*3+1:Necho*4);

% coil2 = coil1; 
% coil3 = coil1; 
% coil4 = coil1; 


% data = temp2(:,2:end,:);
data_1 = coil4(:,:,1);

Icoil1 = ifftshift(ifftn(ifftshift( coil1)));
Icoil2 = ifftshift(ifftn(ifftshift( coil2)));
Icoil3 = ifftshift(ifftn(ifftshift( coil3)));
Icoil4 = ifftshift(ifftn(ifftshift( coil4)));
 
% Icoil1 = ((( coil1(:,:,1))));
% Icoil2 = ((( coil2(:,:,1))));
% Icoil3 = ((( coil3(:,:,1))));
% Icoil4 = ((( coil4(:,:,1))));


figure; mosaic1(abs(rot90(Icoil1)),6,6);
scale1 = [0,0.1];
% 
% figure; imagesc(abs(rot90(Icoil1)));
% scale1 = [0,4];

figure; 
subplot(2,2,1);
mosaic1(abs(rot90(Icoil1)),6,6); colorbar;
caxis(scale1);
title('primary coil');

subplot(2,2,2);
mosaic1(abs(rot90(Icoil2)),6,6);  colorbar;
caxis(scale1);
title('EMI coil 1');

subplot(2,2,3);
mosaic1(abs(rot90(Icoil3)),6,6);  colorbar;
caxis(scale1);
title('EMI coil 2');

subplot(2,2,4);
mosaic1(abs(rot90(Icoil4)),6,6);  colorbar;
caxis(scale1);
title('EMI coil 3');


fclose('all');