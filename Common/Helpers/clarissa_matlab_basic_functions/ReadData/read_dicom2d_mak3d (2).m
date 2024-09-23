function [data, header]=read_dicom2d_mak3d(FLAG_AFF,minx, maxx, miny, maxy, minz,maxz)
% lecture de donn�es DICOM sous forme d'une s�rie d'images 2d repr�sentant
% un volume 3d rang�es dans un r�pertoire
% et fabrication fichier 3D pour visualisation sous MATLAB

% la variable FLAG_AFF permet de visualiser ou non les coupes lues
% par d�faut FLAG_AFF est OFF
% les variables optionnelles minx maxx miny maxy minz maxz servent a pr�r�gler un crop 
% afin de minimiser la taille du fichier repr�sent� au champ utile
% minx, maxx = coordonn�es min et max en X des donn�es conserv�es
% miny, maxy = coordonn�es min et max en Y des donn�es conserv�es
% minz, maxz = coordonn�es min et max en Z des donn�es conserv�es
% par d�faut elles sont � la taille des donn�es...

%fabrique liste contenant les noms des fichiers a lire
listout=BrowseAll;
%d�termination r�pertoire actuel
bidule=pwd;
% d�termination nbre de caracteres a enlever
taille_a_enlever=size(bidule,2);
%d�termination nombre de fichiers a lire
nb_fichier=size(listout,1);
fprintf(1,'\n%d',nb_fichier);
if(nargin<1)
    FLAG_AFF=0;
end;
% d�termination nombre de pixels en x et y 
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
%d�termination nom de chaque fichier    
filename=listout(i,1).name;
% dicomread ne veut que le nom du fichier et pas le chemin d'acces
truc=filename(taille_a_enlever+1:end);
fprintf(1,'\n%s',truc);
% attention les donn�es sont sur 2 octets en int16 et pas uint16
x= int16(dicomread(truc));
% affichage chaque image conserv�e
if(FLAG_AFF==1)
figure;
imagevraiesc(x(minx:maxx,miny:maxy));
end;
%remplissage donn�es
% on ne conserve que les donn�es de la r�gion d'interet pour limiter la
% taille de sortie
data(1:sizex,1:sizey,j)=x(minx:maxx,miny:maxy);
end;