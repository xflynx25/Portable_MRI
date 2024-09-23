function [G,Nx,G0]=Read_LeCroy(offset,calibre)
% Nx nbre de points par ligne
% G signal lu
% offset nbre d'octets avant de lire le signal
% calibre du scope en Volt/division pour se ramener en Volt
% G0 signal en V (?)

% lecture données
[filename,path]=uigetfile('*');
filename=strcat(path,filename);
filenam=strrep(filename, '_', '-');
filenam=strrep(filenam, '\', '');
filenam= filenam(9:21)
% offset trouvé 'a la main' sur fichier 
info=dir(filename);
siz_fich=info.bytes;
Nx=(siz_fich-offset)/2-1;

% offset=359 pour fichier SC1.000 et SC2.000 avec 25000 points;
% format 'long','ieee-be'et 4 octets par point

% offset=359 pour obtenir 25 000 points short pour fichier STA.xxx
% Nx=(siz_fich-offset)/2-1
% lire en format 'short','ieee-le'et 2 octets par point
% et multiplier par échelle totale de numérisation du scope = 20V et / 32768
% OK pour échelle 2 V mais pas pour 0.5...
G=Read_Raw_Field(filename,offset,[Nx,1],'short','ieee-le');
size(G)
G0=G*calibre*10/32768;
deltavoltage=mean(G(650:1850))-mean(G(2000:4999));
[moy_apres_pulse, ecty_apres_pulse]=stat(G(2000:4999));
[moy_pulse, ecty_pulse]=stat(G(650:1850));

figure;
subplot(2,1,1);
plot(G);
affiche=['tension lue (sur 2 octets)' filenam];
title(affiche);
subplot(2,1,2);
plot(G0);
affiche=['tension lue (V?)' filenam];
title(affiche);
fprintf(1,'\nnom fichier\thauteur pulse\tectyp pulse\tectyp post-pulse\n');
fprintf(1,'\n%s\t%f\t%f\t%f\n',filenam,deltavoltage,ecty_pulse,ecty_apres_pulse);