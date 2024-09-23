function [] = mosaicx(xplot, A, n, m)
figure;
for nn = 1:size(A,3)
subplot(n,m,nn);
imagesc(xplot, xplot, A(:,:,nn));
axis square; colormap gray;
end
