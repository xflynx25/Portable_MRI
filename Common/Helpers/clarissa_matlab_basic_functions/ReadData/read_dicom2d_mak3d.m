function [data, header]=read_dicom2d_mak3d(FLAG_AFF,minx, maxx, miny, maxy, minz,maxz)
% lecture de données DICOM sous forme d'une série d'images 2d représentant
% un volume 3d rangées dans un répertoire
% et fabrication fichier 3D pour visualisation sous MATLAB

% la variable FLAG_AFF permet de visualiser ou non les coupes lues
% par défaut FLAG_AFF est OFF
% les variables optionnelles minx maxx miny maxy minz maxz servent a prérégler un crop 
% afin de minimiser la taille du fichier représenté au champ utile
% minx, maxx = coordonnées min et max en X des données conservées
% miny, maxy = coordonnées min et max en Y des données conservées
% minz, maxz = coordonnées min et max en Z des données conservées
% par défaut elles sont à la taille des données...

%fabrique liste contenant les noms des fichiers a lire
listout=BrowseAll;
%détermination répertoire actuel
bidule=pwd;
% détermination nbre de caracteres a enlever
taille_a_enlever=size(bidule,2);
%détermination nombre de fichiers a lire
nb_fichier=size(listout,1);
fprintf(1,'\n%d',nb_fichier);
if(nargin<1)
    FLAG_AFF=0;
end;
% détermination nombre de pixels en x et y 
% par lecture header premier fichier
filename=listout(1,1).name;
truc=filename(taille_a_enlever+1:end);
fprintf(1,'\n%s',truc);
header=dicominfo(truc);
NX=header.Rows;
NY=header.Columns;

if(nargin<2)
    minx=1;
    miny=1;
    minz=1;
    maxx=NX;
    maxy=NY;
    maxz=nb_fichier;
end;
sizex=maxx-minx+1;
sizey=maxy-miny+1;
sizez=maxz-minz+1;

for i=minz:maxz
    j=i-minz+1;
%détermination nom de chaque fichier    
filename=listout(i,1).name;
% dicomread ne veut que le nom du fichier et pas le chemin d'acces
truc=filename(taille_a_enlever+1:end);
fprintf(1,'\n%s',truc);
% attention les données sont sur 2 octets en int16 et pas uint16
x= int16(dicomread(truc));
% affichage chaque image conservée
if(FLAG_AFF==1)
figure;
imagevraiesc(x(minx:maxx,miny:maxy));
end;
%remplissage données
% on ne conserve que les données de la région d'interet pour limiter la
% taille de sortie
data(1:sizex,1:sizey,j)=x(minx:maxx,miny:maxy);
end;