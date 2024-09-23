function [header] = Read_FID_Header(filename,trace,nbpt,offset1)

% initialisation du header
header=[];

% verification sur l'entree
if (nargin==0)
    % ouverture de .raw specifiquement
    [filename,path]=uigetfile('*.*');
    filename=strcat(path,filename);
else
    if(exist(filename)==2)
        % descriptif du fichier
        s=dir(filename);
        % verification de la taille du fichier
        if s.bytes>4498
        
            % lecture data à lire
        Hdr_var=Read_FID_hdr;

        % extraction un a un des tableaux
        Hdr_name=Hdr_var(:,1:28);
        Hdr_offset=Hdr_var(:,29:34);
        Hdr_type=Hdr_var(:,36:44);
        Hdr_size=Hdr_var(:,45:47);
        Hdr_desc=Hdr_var(:,48:85);
        
        % function strrep pour enlever les espaces.
    
        Number_var=size(Hdr_name);
        
        % ouverture du fichier, precision de big ou little endian ici
        File_pt=fopen(filename,'r','ieee-le');
        
                % boucle sur les variables
        for i=1:Number_var(1,1)
            Var_name=strrep(Hdr_name(i,:),' ','');
            Var_offset=4*trace*(offset1+nbpt)+eval(Hdr_offset(i,:));
            Var_type=strrep(Hdr_type(i,:),' ','');
            Var_size=eval(Hdr_size(i,:));
            Var_desc=Hdr_desc(i,:);
            
            % deplacement à l'offset
            fseek(File_pt,Var_offset,'bof');
            Var_data=fread(File_pt,Var_size,Var_type)';
            if (strcmp(Var_type,'char'))&((Var_size-1)>0)
                Var_data=char(Var_data);
            end
            
            % header est une structure avec le champs .variable
            eval(strcat('header.',Var_name,'=Var_data;'));
        end
        % fermeture du fichier
        fclose(File_pt);
    end
end
end