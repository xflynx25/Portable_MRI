function [] = imgood(A)

imagesc(squeeze(abs(A)));  
axis square;
colormap gray;
