function [Ms]=Read_fld(filename)
% lecture de donnees de type .fld
% 23 nov 2004 semble marcher de facon robuste pour lire 
% les fichiers de manips ex-Magnetech
Ms=[];

if (nargin==0)
    [filename,path]=uigetfile('*.fld');
    filename=strcat(path,filename);
end
fprintf(1,'\n%s',filename);
s=dir(filename);
si=size(s);
 
[offset,dsize,typ_data]=Read_fld_Header(filename);
Nx=dsize(2);
Ny=dsize(3);
Nz=dsize(4);
     
% lecture des données
M0=Read_Raw_Field(filename,offset,[2,Nx,Ny,Nz],typ_data,'b');
size(M0)

%reorganisation des données
if max(size(M0))~=0
M0=M0(1,:,:,:)+j*M0(2,:,:,:);
% matrice complexe
Ms=reshape(M0,Nx,Ny,Nz);                                
else
Ms=[];
end