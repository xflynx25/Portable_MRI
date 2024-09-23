function [offset,dsize,typ_data]=Read_fld_Header(filename)
%lecture de header ASCII des fichiers .fld
% determination taille et type des data a lire
% determination taille de l'offset
% marche a peu pres... pour une raison obscure (23 nov 2004) 
%je n'ai pas réussi a automatiser la lecture du nombre de lignes ASCII
% par defaut lire 12 lignes marche, mais pourrait etre insuffisant?
header=[];
if (nargin<1)
    [filename,path]=uigetfile('*.fld');
    filename=strcat(path,filename);
end
nline=0;
offset=0; 
if(exist(filename)==2)
    s=dir(filename);
    File_pt=fopen(filename,'rt');
    while feof(File_pt)==0
       sline=fgetl(File_pt);
       nline=nline+1;
     end;
     fprintf(1,'\nnombre de lignes du Header Ascii: %d',nline);
     %probleme ne marche pas... le eof est trouve trop tot 1/4 fois?
     fseek(File_pt,0,'bof');
        for i=1:12
            tline=fgetl(File_pt);
            s=size(tline,2);
            fprintf(1,'\n%s',tline);
            offset=offset+s;
            %fprintf(1,'\nlig %d\tnombre char %d\tcumul offset %d',i,s,offset);
            if(i==3)ndim=str2num(tline(1,6:s));end;
            if(i==4)dsize(2)=str2num(tline(1,6:s));end;
            if(i==5)dsize(3)=str2num(tline(1,6:s));end;
            if(i==6)dsize(4)=str2num(tline(1,6:s));end;
            if(i==8)dsize(1)=str2num(tline(1,8:s));end;
            if(i==9)typ_data=tline(1,6:s);end;
        end;
        %end du for i=1:nline
    offset=offset+14;
    % experimentalement offset=nb de char par
    % ligne)*(nb de lignes ASCII vues a l'oeil).. a améliorer
    
    fclose(File_pt);
    %ndim
    %dsize
    %size(dsize)
    %typ_data
    %offset
end;
% end de if exist