function h = circlephantom(FOV, Nrecon, radius, yoffset, zoffset)
%%everything in cm

% FOV = 24; Nrecon = 128;  radius = 0.2; yoffset = 8; zoffset = 3;

res = FOV/(Nrecon-1);
yvec = linspace(-FOV/2,FOV/2,Nrecon);
yoffset_pts = round(yoffset/res);
zoffset_pts = round(zoffset/res);

[xx,yy] = ndgrid(yvec,yvec);

I = find(sqrt(xx.^2+yy.^2) <radius);

h = zeros(size(xx));
h(I) = 1;

h2 = circshift(h, [zoffset_pts, yoffset_pts]);



figure; imagesc(yvec,yvec,h2)