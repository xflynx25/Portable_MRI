function maskout = mask0(FOV, Nrecon)

maskout = ones(Nrecon,Nrecon);

[XX,YY] = meshgrid(linspace(-FOV/2,FOV/2,Nrecon),linspace(-FOV/2,FOV/2,Nrecon));


I = sqrt(XX.^2+YY.^2) >= FOV/2;



maskout(I) = 0;