% !   This file contains time domain data in the spectral dimension.
% 
% !   S15/ACS: set of *.SPAR and *.SDAT files is created, (dataformat: VAX CPX floats)

% Un petit module matlab  read_MRS.m.pour lire les donn�es spectro de Philips
% (il s'agit de format "VAX" !!!! Pas facile � imaginer mais c'�tait marqu� dans un coin)
% 
% Il traite en bloc tous les fichiers SDAT du r�pertoire courant
% 
% le module interpr�te les donn�es comme du bruit, en calcule l'�cart-type sur la partie r�elle et imaginaire avant TF et exporte ceci sur une feuille XLS
% 
% attach� aussi un module de Ludovic que j'utilise dans le mien et qq exemples pour tester
% 
% NB : 	- pour l'utiliser, il faut �videmment adapter le chemin d'acc�s �crit au tout d�but du .m
% 	- si on veut juste lire les donn�es et en faire une autre exploitation, il faut l'adapter
% 	- de m�me, il lit 1024 points mais ce n'est pas bien difficile � changer voire � automatiser en extayant l'information du fichier SPAR correspondant.
% 

clear all

repertoire = '.';   % � changer si on veut travailler ailleurs que dans le r�pertoire courant
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
    S = fread(fichier,[2,1024], 'float32', 0, 'vaxg').';    % vaxg ou vaxd ont l'air de donner le m�me r�sultat
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
