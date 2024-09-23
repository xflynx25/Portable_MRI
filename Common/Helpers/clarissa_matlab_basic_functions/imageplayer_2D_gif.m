% 
% load('orange_3d_images_initalrecon_4_16_17.mat');
% load('circle_mit_3d_images_initalrecon_4_16_17.mat');
% load('lemon2b_3d_images_initalrecon_4_17_17.mat');
% load('pepper_3d_images_initalrecon_4_17_17.mat');
% % load('lemon1_3d_images_initalrecon_4_17_17.mat');

% load('lemon_recon_rsna_2017.mat');
load('lemon181_512voxels_2iters_30-Oct-2017.mat');
reconorig = recon; reconall = [];
reconall = squeeze(reconorig(:,:,1,:,:));

numframes = 181;
frame = 0;
A=moviein(numframes); % create the movie matrix 
set(gca,'NextPlot','replacechildren') 
Ninterp =200;


figure; jj=1;
for ii = 1:181; 
%       subplot(4,9,ii)
%       subplot(3,5,jj)

    imagesc(abs(rot90((reconall(:,:,ii,1)))));
    colormap gray; %caxis([0, 250]);
    axis square; 
    title(['rot = ',num2str(ii)]);
     pause(0.1);
     jj=jj+1;
             frame = frame +1;
        A(:,frame)=getframe; 
end

for ii = 2:3; 
%       subplot(4,9,ii)
%       subplot(3,5,jj)

    imagesc(abs(rot90((reconall(:,:,181,ii)))));
    colormap gray; %caxis([0, 250]);
    axis square; 
    title(['rot = ',num2str(ii)]);
     pause(0.1);
     jj=jj+1;
             frame = frame +1;
        A(:,frame)=getframe; 
end


movie2gif(A, 'lemonrsnav5.gif', 'DelayTime', .05,'LoopCount', 1)

% 
% 
% 
% % figure;
% % %imagesc(fm);
% % imagesc(linspace(-10,10,Ninterp), linspace(-10,10,Ninterp), fm); axis square;  colormap jet;
% % caxis([Bave-.7, Bave+0.7]);
% % xlabel('Y (cm)'); ylabel('Z (cm)');
% %  set(gca,'FontSize',20,'FontWeight','Bold');
% % title(['X = -4 cm'],'FontSize',26);
% % 
% % 
% % ang = [0:2:180];
% 
% 
% 
% figure; jj=1;
% for ii = 1:31; 
% %       subplot(4,9,ii)
% %       subplot(3,5,jj)
% 
%     imagesc(abs(rot90((reconall(:,:,ii)))));
%     colormap gray; caxis([0, 250]);axis square; 
%     title(['slice = ',num2str(ii)]);
%      pause(0.1);
%      jj=jj+1;
%              frame = frame +1;
%         A(:,frame)=getframe; 
% end
% 
% movie2gif(A, 'pepperv1', 'DelayTime', .1,'LoopCount', inf)
% 
% for ii = 30:-1:2; 
% %       subplot(4,9,ii)
% %       subplot(3,5,jj)
% 
%     imagesc(abs(rot90((reconall(:,:,ii)))));
%     colormap gray; caxis([0, 250]);axis square; 
%     title(['slice = ',num2str(ii)]);
%      pause(0.1);
%      jj=jj+1;
%              frame = frame +1;
%         A(:,frame)=getframe; 
% end
% 
% movie2gif(A, 'pepperv1', 'DelayTime', .1,'LoopCount', inf)
% 
% 
% % 
% % for aa = 1:91
% % fmtemp = imrotate(fm, ang(aa),'crop');
% % % imagesc(flipud(temp.*coil_mask));
% % 
% % 
% % % imagesc(linspace(-10,10,Ninterp), linspace(-10,10,Ninterp), fmtemp); axis square;  colormap jet;
% % % caxis([Bave-.7, Bave+0.7]);xlabel('Y (cm)'); ylabel('Z (cm)');
% % %  set(gca,'FontSize',20,'FontWeight','Bold');
% % % title(['X = -4 cm'],'FontSize',26);
% % 
% % axis square
% % axis off
% % pause(.01)
% %         frame = frame +1;
% %         A(:,frame)=getframe; 
% % end;
% % 
