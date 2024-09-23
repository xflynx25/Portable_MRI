% !   This file contains time domain data in the spectral dimension.
% 
% !   S15/ACS: set of *.SPAR and *.SDAT files is created, (dataformat: VAX CPX floats)

% Un petit module matlab  read_MRS.m.pour lire les données spectro de Philips
% (il s'agit de format "VAX" !!!! Pas facile à imaginer mais c'était marqué dans un coin)
% 
% Il traite en bloc tous les fichiers SDAT du répertoire courant
% 
% le module interprète les données comme du bruit, en calcule l'écart-type sur la partie réelle et imaginaire avant TF et exporte ceci sur une feuille XLS
% 
% attaché aussi un module de Ludovic que j'utilise dans le mien et qq exemples pour tester
% 
% NB : 	- pour l'utiliser, il faut évidemment adapter le chemin d'accès écrit au tout début du .m
% 	- si on veut juste lire les données et en faire une autre exploitation, il faut l'adapter
% 	- de même, il lit 1024 points mais ce n'est pas bien difficile à changer voire à automatiser en extayant l'information du fichier SPAR correspondant.
% 

clear all

repertoire = '.';   % à changer si on veut travailler ailleurs que dans le répertoire courant
% cd(repertoire)

structfiles=Browse(repertoire,'.SDAT');

listfiles=struct2cell(structfiles);
listfiles=listfiles(1,:)

sortedfiles=sort(listfiles);
Nmax=size(listfiles,2)

L=[];
for n=1:Nmax
    filename = cell2mat(sortedfiles(n))
    fichier = fopen(filename, 'r');
    S = fread(fichier,[2,1024], 'float32', 0, 'vaxg').';    % vaxg ou vaxd ont l'air de donner le même résultat
    fclose(fichier)
    
    Re=S(:,1);
    Im=S(:,2);
    Cx=Re+i*Im;
    Mg=abs(Cx);
    Ph=angle(Cx);

    FCx=fftshift(fft(fftshift(Cx)));
    FRe=real(FCx);
    FIm=imag(FCx);
    FMg=abs(FCx);
    FPh=angle(FCx);

    sdre=std(Re);
    sdim=std(Im);
    sd=(sdre+sdim)/2;




    close all
    subplot(4,2,1)
    plot(Re,'r')
    title(['Reelle : SD = ',num2str(sdre)])
    hold on 
    subplot(4,2,3)
    plot(Im,'b')
    title(['Imag. : SD = ',num2str(sdim)])
    subplot(4,2,5)
    plot(Mg,'k')
    title(['Module (SDmoy = ',num2str(sd),')'])
    subplot(4,2,7)
    plot(Ph,'g')
    title('Phase')

    subplot(4,2,2)
    plot(FRe,'r')
    title('TF Reelle')
    hold on 
    subplot(4,2,4)
    plot(FIm,'b')
    title('TF Imaginaire')
    subplot(4,2,6)
    plot(FMg,'k')
    title('TF Module')
    subplot(4,2,8)
    plot(FPh,'g')
    title('TFPhase')

    h=get(gca);
    p=h.Parent;
    saveas(p,[filename(1:end-5),'.jpg'],'jpg')

    [pathstr, name, ext, versn] = fileparts(filename);
    xlswrite([pathstr,'\synthese_auto.xls'], {name,sd} ,'sd_bruit',['A' num2str(n,'%d')])

end
