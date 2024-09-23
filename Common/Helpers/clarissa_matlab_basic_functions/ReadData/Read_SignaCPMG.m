function [A,filenames,AC]=Read_SignaCPMG(filename, nbechos)
% lecture amplitude complexe et amplitude d'un fichier SIGNA cpmg
% appel a cette fonction:
% A=Read_SignaCPMG('nomfichier', 128)
% renvoie l'amplitude du nombre complexe comme une matrice Nx*128
% si on veut recuperer le nombre complexe c'est aussi possible par AC
[filename,path]=uigetfile('*.raw');
filenames=strcat(path,filename);

s=dir(filename);
si=size(s);
if si(1,1)==1
Header=Read_Signa_Header(filename);
end;
if size(Header)~=[0 0]
        Nx=Header.rdb_hdr_frame_size;
    end;
%lecture "automatique" du nombre de points par echo
offset=39940;
%toujours ce meme offset pour CPMG
AC=Read_Raw_Field(filename,offset,[2,Nx,nbechos],'long','b');
AC=AC(1,:,:,:)+j*AC(2,:,:,:);
%rearrangement des donnees
AC=reshape(AC,Nx,nbechos);
A=abs(AC);
