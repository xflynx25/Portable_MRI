function P0 = rectanglephantom(N,FOV)
% N = 256;
% FOV = 24;
xx = linspace(-FOV/2,FOV/2,N);


yi = ((-1 < xx) & (xx < 1));
zi = ((-10 < xx) & (xx < 10));

P0 = zeros(N,N);
P0(yi,zi) = 1;

figure; imagesc(P0);