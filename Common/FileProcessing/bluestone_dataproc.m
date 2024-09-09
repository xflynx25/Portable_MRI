clear all;


titledis = 'mgh short coil bottle pd';

% data_string = 'E:\DATA_bluestone\20240528\PD_lowres_negRO_refphantom_shorthelmet_EMI.tnt';

%data_string = 'E:\DATA_bluestone\20240528\PD_lowres_negRO_refphantom_shorthelmet_lowsig_EMI_VNAEMI.tnt';


projectdata = './Projects/editor_tf_fits/Data';
data_string = fullfile(projectdata, 'Raw/clarissa_3d_latemay/PD_lowres_negRO_refphantom_shorthelmet_lowsig_EMI_VNAEMI.tnt');

[ Ms1, Header, Var_data ] = Read_Tecmag(data_string);


noisecal = 1;
usephasecorrection = 0;
EMIacq = 1;
snrcalc = 1;
snrpart = 15;


% %choose for "high res" in z
% gpeztable = [0, -100:2:100];

%choose for "low res" in z
gpeztable = [0, -28:2:50];


%%choose for PD or T1 sequence (center-out ordering)
Gx0a = [0:4:40];
Gx0b = [-4:-4:-40];
Gx0c = [44:4:68];
Gx0 = zeros(1,numel(Gx0a)+numel(Gx0b));
Gx0(1:2:end) = Gx0a;
Gx0(2:2:end) = Gx0b;
Gx0 = [Gx0,Gx0c];
gpextable = [Gx0, 0,0];

%%choose for T2 sequence
% gpextable = [-32:4:68,-36,-38,0,0];


if EMIacq == 1
    Necho = numel(gpextable)*4;
else
    Necho = numel(gpextable)*2;
end
Nechosing = numel(gpextable)*2;

Npe_all = numel(gpeztable);
Nro   = 256;


%% data reorder and navigator phase correction

if noisecal == 1
    Ms_reorder_pos = tntreshape(Ms1, Nro, Necho+2);
    noisedat = squeeze(Ms_reorder_pos([Nechosing+1],:,:));
    Ms_reorder_pos = Ms_reorder_pos([1:Nechosing,Nechosing+2:end-1],:,:);
    noisecalc = median(std(noisedat));
    disp(['noise std = ',num2str(noisecalc)]);
    
else
    Ms_reorder_pos = tntreshape(Ms1, Nro, Necho);
end

[dataFID1, dataSpec1] = phasecorr_EMI(usephasecorrection, Ms_reorder_pos, Necho, Npe_all, EMIacq);

if noisecal == 1
    nav1 = squeeze(dataFID1(:,1,30));
    maxnav = max(abs(nav1));
    disp(['nav amp = ',num2str(maxnav)]);
    navSNR = maxnav/noisecalc;
    disp(['nav SNR = ',num2str(navSNR)]);
end


dataFID = dataFID1;%+dataFID2;%+dataFID3+dataFID4+dataFID5+dataFID6;
% dataFID_nopad = dataFID(:,2:end,1:Necho/4);

if EMIacq == 1
    dataFID_nopad = dataFID(:,2:end,1:Necho/4);
    dataEMI_nopad = dataFID(:,2:end,Necho/4+1:end);
else
    dataFID_nopad = dataFID(:,2:end,:);
end


%% zeropadding and kspace re-ordering for T2 weighted sequence
zorder0 = [2:numel(gpeztable)];
xorder1 = [1:numel(gpextable)-2];

gpextable2 = gpextable(1:end-2);
temp=numel(gpextable2);
[B,I] = sort(gpextable2);

gpeztable2 = gpeztable(2:end);
[Bz,Iz] = sort(gpeztable2);

% dataFIDpad = zeros(Nro,101,35);
dataFIDpad = zeros(Nro,41,35);


% dataFIDpad(:,end-numel(zorder0)+1:end,end-numel(xorder1)+1:end) = dataFID_nopad(:,zorder0,xorder1) ;
% dataFIDpad(:,end-numel(zorder0)+1:end,1:9) = dataFID_nopad(:,zorder0,[35:-1:27]) ;

% dataFIDpad(:,end-numel(zorder0)+1:end,end-numel(xorder1)+1:end) = dataFID_nopad(:,Iz,I) ;
dataFIDpad(:,end-numel(zorder0)+1:end,end-numel(xorder1)+1:end) = dataFID_nopad(:,Iz,I) ;
dataFID_nopad2 = dataFID_nopad(:,Iz,I) ;

dataFID = dataFID_nopad2;  %%% dataSpec = dataSpecpad;
% dataFID = dataFIDpad;  %%% dataSpec = dataSpecpad;


if EMIacq == 1
    %repeat reordering with emi data
    zorder0 = [2:numel(gpeztable)];
    xorder1 = [1:numel(gpextable)-2];
    
    %     dataFIDpadEMI = zeros(Nro,101,35);
    dataFIDpadEMI = zeros(Nro,41,35);
    
    dataFIDpadEMI(:,end-numel(zorder0)+1:end,end-numel(xorder1)+1:end) = dataEMI_nopad(:,Iz,I) ;
    dataFIDEMI_nopad2 = dataEMI_nopad(:,Iz,I(1:end)) ;
    
    
    dataFIDEMI = dataFIDEMI_nopad2;  %%zero pad z and y dimension
    
    
end



%%
my_method = 0; 

%% FFTing
% % %
% I3Dfid = ifftshift(ifftn(ifftshift(dataFID(65:end-64,:,:))));
I3Dfid = ifftshift(ifftn(ifftshift(dataFID)));
I3Dfidemi = ifftshift(ifftn(ifftshift(dataFIDEMI)));

if EMIacq == 1
    if my_method == 0
        %     data2d = ifftshift(ifft(ifftshift(dataFID(65:end-64,:,:),3),[],3),3);
        %     data2dEMI = ifftshift(ifft(ifftshift(dataFIDEMI(65:end-64,:,:),3),[],3),3);
        data2d = ifftshift(ifft(ifftshift(dataFID,3),[],3),3);
        data2dEMI = ifftshift(ifft(ifftshift(dataFIDEMI,3),[],3),3);
        
        
        for ii = 1:size(data2d,3)
            I3D_Editer(:,:,ii) =  EDITER_1emicoil_func(data2d(:,:,ii),data2dEMI(:,:,ii));
        end
    end 
    if my_method == 1
        combined_data = cat(4, dataFID, dataFIDEMI);
        I3D_Editer = Editer_3d_transform(combined_data, 'phaseslice');
        datafft_combined = combined_data; 

    end 

       figure;
    mosaicrot270(abs(I3Dfid),6,6);
    title(titledis);
 caxis([0,2])
    title('without editer')
    
    
    figure;
    subplot(2,2,1)
    mosaicrot270(abs(I3Dfid),6,6);
    title(titledis);
 caxis([0,1])
    title('without editer')
%     saveas(gcf,'alex_test.png')

    subplot(2,2,2)
    mosaicrot270(abs(I3D_Editer),6,6);
    caxis([0,1])
    title('with editer')
    
    subplot(2,2,3)
    mosaicrot270((abs(I3Dfid) - abs(I3D_Editer)),6,6);
%     caxis([0,0.01])
    title('difference')
    
 
    subplot(2,2,4)
    mosaicrot270(abs(I3Dfidemi),6,6);
    title(titledis);
%  caxis([0,0.05])
    title('EMI image')
    
else
    
    figure;
    mosaicrot270((abs(I3Dfid)),6,6);
     caxis([0,2])
    title('without editer')
    
end

if snrcalc == 1

% SNR calc based on ROI
h = figure;

Isnr = (abs(I3Dfid(:,:,snrpart)));
imagesc(Isnr);  colormap gray;
caxis([0,3])

% load('snr_coords.mat');
disp('select sig region for snr calc');
hsig = imrect(gca);
hcoordsig = round(getPosition(hsig));
sig = mean(mean(Isnr(hcoordsig(2):hcoordsig(2)+hcoordsig(4),hcoordsig(1):hcoordsig(1)+hcoordsig(3))));
% figure; imagesc(I(hcoordsig(2):hcoordsig(2)+hcoordsig(4),hcoordsig(1):hcoordsig(1)+hcoordsig(3)));

disp('select noise region for snr calc');
hnoise = imrect(gca);
setColor(hnoise, 'red');
hcoordnoise = round(getPosition(hnoise));
noisevec = Isnr(hcoordnoise(2):hcoordnoise(2)+hcoordnoise(4),hcoordnoise(1):hcoordnoise(1)+hcoordnoise(3));
noise = (std(noisevec(:)));

delete(hsig);  delete(hnoise);

SNR = sig/noise
%

disp(['sig=',num2str(sig),', noise=',num2str(noise),', SNR=',num2str(SNR)])
end




fclose('all');
