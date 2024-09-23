clear all;
% close all;

data_string = 'E:\DATA_bluestone\20230123\HP_test_full_16amp.tnt';
[ Ms1, Header, Var_data ] = Read_Tecmag(data_string);
% 
% data_string = 'E:\DATA_bluestone\20221207\CHORUS_STD_100kHz_Gain_18_2022P03_2.5sdelay_run1.tnt';
% [ Ms1, Header, Var_data ] = Read_Tecmag(data_string);

% data_string = 'E:\DATA_bluestone\20221207\CHORUS_STD_100kHz_Gain_18_2022P03_2.5sdelay_run2.tnt';
% [ Ms2, Header, Var_data ] = Read_Tecmag(data_string);
% 
% data_string = 'E:\DATA_bluestone\20221207\CHORUS_STD_100kHz_Gain_18_2022P03_2.5sdelay_run3.tnt';
% [ Ms3, Header, Var_data ] = Read_Tecmag(data_string);
% 
% data_string = 'E:\DATA_bluestone\20221207\CHORUS_STD_100kHz_Gain_18_2022P03_2.5sdelay_run4.tnt';
% [ Ms4, Header, Var_data ] = Read_Tecmag(data_string);

usephasecorrection = 1;
snrcalc = 0;
snrpart = 21;
gpextable = [-32:4:68,0,0];
gpeztable = [0, -60:2:100];
Necho = 60;
Npe_all = 82;
Nro   = 256;


%% data reorder and navigator phase correction
Ms_reorder_pos = tntreshape(Ms1, Nro, Necho);
[dataFID1, dataSpec1] = phasecorr_v3(usephasecorrection, Ms_reorder_pos, Necho, Npe_all);

% Ms_reorder_pos = tntreshape(Ms2, Nro, Necho);
% [dataFID2, dataSpec2] = phasecorr_v3(usephasecorrection, Ms_reorder_pos,Necho, Npe_all);
% 
% Ms_reorder_pos = tntreshape(Ms3, Nro, Necho);
% [dataFID3, dataSpec3] = phasecorr_v3(usephasecorrection, Ms_reorder_pos,Necho, Npe_all);
% 
% Ms_reorder_pos = tntreshape(Ms4, Nro, Necho);
% [dataFID4, dataSpec4] = phasecorr_v3(usephasecorrection, Ms_reorder_pos,Necho, Npe_all);
% 
% dataFID = dataFID1+dataFID2+dataFID3+dataFID4;
dataFID_nopad = dataFID1;
dataSpec_nopad = dataSpec1;



%% zeropadding and kspace re-ordering for T2 weighted sequence

zorder0 = [2:numel(gpeztable)];
xorder1 = [1:numel(gpextable)-2];

dataFIDpad = zeros(Nro,101,35);
dataSpecpad = zeros(Nro,101,35);

dataFIDpad(:,end-numel(zorder0)+1:end,end-numel(xorder1)+1:end) = dataFID_nopad(:,zorder0,xorder1) ;
dataSpecpad(:,end-numel(zorder0)+1:end,end-numel(xorder1)+1:end) = dataSpec_nopad(:,zorder0,xorder1) ;

dataFIDpad(:,end-numel(zorder0)+1:end,8:9) = dataFID_nopad(:,zorder0,27:28) ;
dataSpecpad(:,end-numel(zorder0)+1:end,8:9) = dataSpec_nopad(:,zorder0,27:28) ;

dataFIDpad(:,end-numel(zorder0)+1:end,1:7) = dataFID_nopad(:,zorder0,27:28) ;
dataSpecpad(:,end-numel(zorder0)+1:end,1:7) = dataSpec_nopad(:,zorder0,27:28) ;



dataFID = dataFIDpad;  %%zero pad z and y dimension
dataSpec = dataSpecpad;

% dataFID = dataFIDnopad;  %%zero pad z and y dimension
% dataSpec = dataSpecnopad;

Npx = size(dataSpec,3);
Npz = size(dataSpec,2);




%%

%% FFTing
% % % 
I3Dfid = ifftshift(ifftn(ifftshift(dataFID)));
I3Dspec = ifftshift(ifftn(ifftshift(dataSpec)));

% I3Dfid = ifftshift(ifftn(ifftshift(dataFID(65:end-64,:,:))));
% I3Dspec = ifftshift(ifftn(ifftshift(dataSpec(65:end-64,:,:))));


% % I3Dfid = ifftshift(ifftn(ifftshift(dataFID(85:end-84,25:end-24,:))));
% figure;
% mosaicrot270((abs(I3Dfid(:,:,7:end))),4,6);
% title('fid Echo image - negative RO - active TR switch');
% % caxis([0,2])
% 

figure;
mosaicrot270((abs(I3Dfid)),6,6);
title('spiral coil, chorus, odd echo - 12-07-22');
% caxis([0,0.8])



figure;
imagesc(rot270(abs(I3Dfid(:,:,snrpart))));
title('fid Echo image');
colormap gray;
% caxis([0,1])



if snrcalc == 1

% SNR calc based on ROI
h = figure;

I = (abs(I3Dfid(:,:,snrpart)));
imagesc(I);  colormap gray;


% load('snr_coords.mat');
disp('select sig region for snr calc');
hsig = imrect(gca);
hcoordsig = round(getPosition(hsig));
sig = mean(mean(I(hcoordsig(2):hcoordsig(2)+hcoordsig(4),hcoordsig(1):hcoordsig(1)+hcoordsig(3))));
% figure; imagesc(I(hcoordsig(2):hcoordsig(2)+hcoordsig(4),hcoordsig(1):hcoordsig(1)+hcoordsig(3)));

disp('select noise region for snr calc');
hnoise = imrect(gca);
setColor(hnoise, 'red');
hcoordnoise = round(getPosition(hnoise));
noisevec = I(hcoordnoise(2):hcoordnoise(2)+hcoordnoise(4),hcoordnoise(1):hcoordnoise(1)+hcoordnoise(3));
noise = (std(noisevec(:)));

delete(hsig);  delete(hnoise);

SNR = sig/noise
%

disp(['sig=',num2str(sig),', noise=',num2str(noise),', SNR=',num2str(SNR)])
end

fclose('all');
