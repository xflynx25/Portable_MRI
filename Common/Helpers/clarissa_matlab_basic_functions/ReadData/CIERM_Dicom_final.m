% CIERM DICOM Reader
%===============================================================
% olivier Girard / Sabin Carme
%===============================================================
%
% Attention optimisé pour les images du CIERM
%
%===============================================================
% Comments:
%===============================================================
% $Id:  $
% $Revision: 1.1.1.1 $  
% $Date: 2004/10/06 08:08:04 $
%===============================================================
%   Copyright 2004 GUERBET GROUP IMEX.
%===============================================================
clear all

%%On se place dans le bon repertoire
%cd('D:\Unite de Recherche\Projets de recherche\Bobines_nodales\Donnees');

%%%%%%
[filename, dir_path] = uigetfile('*.*','Load Work Directory and clik the first image of the sequence');
cd (dir_path);
pwd

date=input('donnez la date');
date=num2str(date);

%%%%%%%%%%%%%%%%%%%%%%%%%
%dicom_ext='*.dcm';
dicom_ext='';
    if isempty(dicom_ext)
        Dicom_dir = dir([dir_path]);
    else
        Dicom_dir = dir([dir_path,dicom_ext]);
    end

    
%% On compte le nb de fichiers dicom dans le repertoire    
%%%%%%%%%%%%%%%%%%%%%%%%%%%
[num_files] = size(Dicom_dir); 
num_files=num_files(1)-2; % saute le . et .. 

%tabfile=zeros(4,num_files);		% File number arrangement into work Dir
DirName=sprintf('%s\\',pwd)    
  



%% Initialisation des paramètres de sequence
%%%%%%%%%%%%%%%%%%%%%%%%%
Info.Filename=[] ;
Info.SeriesDescription=[];
Info.SeriesNumber=[];
Info.PatientPosition=[];              
Info.Format=[];      
Info.Manufacturer=[];
Info.InstitutionName=[];
Info.SequenceName=[];
Info.ScanningSequence=[];
Info.FileModDate=[];
Info.ProtocolName=[];
%%%%%%%%%%%%
Info.SliceThickness=[];              
Info.FlipAngle=[];              
Info.RepetitionTime=[];
Info.EchoTime=[];
Info.Rows=[];
Info.Columns=[];
Info.PixelSpacing=[];
%%%%%%%%%%%%%%%%%%%%%%%    



%% clase chaque image avec son acquisition number
  indice=1;
  waitHld=waitbar(0,'Analyzing DICOM files');
    for i=3:num_files+2   % saute le . et .. 
        fullpathname = [DirName,Dicom_dir(i).name];
        Dicom_Info(indice)=dicominfo(fullpathname);
        
%         tabfile(1,indice)= Dicom_Info(indice).AcquisitionNumber;
%         tabfile(2,indice)= Dicom_Info(indice).InstanceNumber;
%         tabfile(3,indice)= Dicom_Info(indice).SeriesNumber;
%         tabfile(4,indice)= squeeze(Dicom_Info(indice).Filename);
%        

            tabfile(indice).acq= Dicom_Info(indice).AcquisitionNumber;
            tabfile(indice).inst= Dicom_Info(indice).InstanceNumber;
            tabfile(indice).serie= Dicom_Info(indice).SeriesNumber;
            tabfile(indice).filename= Dicom_Info(indice).Filename;
         
        acq=tabfile(indice).acq
        inst=tabfile(indice).inst
        serie=tabfile(indice).serie
        filename=tabfile(indice).filename
        
        waitbar(indice/num_files,waitHld);
        indice=indice+1;
    end
    close(waitHld);

    
    
    
if(1)   
    
    
 serie=Dicom_Info(1).SeriesNumber;;    
     
   
     
   % reclasse les images en fonction du header
    for k=1 : num_files 
        
        % for tabfile(indice).serie
%     
%     Dicom_Info(index).SeriesNumber=tabfile(indice).serie;
    %%
    %Structure de données GOA pour les  *.mat
    %%--> DataMRI.Data_Info
    %%--> DataMRI.Data_Param
    %%--> DataMRI.Data_Instance
    
    
    index=k;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%--> DataMRI.Data_Info
    Data_Info.FileName=DirName;
    Data_Info.StudyName=Dicom_Info(index).SeriesDescription;
    Data_Info.SeriesNumber=Dicom_Info(index).SeriesNumber;
    Data_Info.PatientPosition=Dicom_Info(index).PatientPosition;              
    Data_Info.Format=Dicom_Info(index).Format;      
    Data_Info.ScannerManufacturer=Dicom_Info(index).Manufacturer;
    Data_Info.InstitutionName=[];
    Data_Info.SequenceName=Dicom_Info(index).SequenceName;
    Data_Info.ScanningSequence=Dicom_Info(index).ScanningSequence;
    Data_Info.FileModDate=Dicom_Info(index).FileModDate;
    Data_Info.Protocole=Dicom_Info(index).ProtocolName;
    %%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%--> DataMRI.Data_Param
    Data_Param.SliceThickness=Dicom_Info(index).SliceThickness;              
    Data_Param.FlipAngle=Dicom_Info(index).FlipAngle;              
    Data_Param.RepetitionTime=Dicom_Info(index).RepetitionTime;
    Data_Param.EchoTime=Dicom_Info(index).EchoTime;
    Data_Param.Matrix=[];
    Data_Param.Rows=Dicom_Info(index).Rows;
    Data_Param.Columns=Dicom_Info(index).Columns;
    Data_Param.PixelSpacing=Dicom_Info(index).PixelSpacing;
    %%%%%%%%%%%%
    Rows=Dicom_Info(index).Rows;
    PixelRows=Dicom_Info(index).PixelSpacing(1);
    Columns=Dicom_Info(index).Columns;
    PixelColumns=Dicom_Info(index).PixelSpacing(2);
    %%
    Data_Param.FOV(1)=Columns*PixelColumns;
    Data_Param.FOV(2)=Rows*PixelRows;
    %%%%%%%%%%%%            
    Data_Param.NbFrame=1;
    Data_Param.NbSlice=1;
   
     
   

        
        if(tabfile(k).serie==serie)
            %%Data_Instance.Data_Image(x,y, RGB,z,t);
            Data_Instance.Data_Image(:,:,:,tabfile(k).inst,1)=double( DicomRead(tabfile(k).filename) );
            serie=tabfile(k).serie;          
                                        
        else
            
            %%%%%
            Data_Param.NbSlice=tabfile(k-1).inst
            Data_Info.SeriesNumber=num2str(serie);
            %%
            Data_MRI.Data_Instance=Data_Instance;
            Data_MRI.Data_Info=Data_Info;
            Data_MRI.Data_Param=Data_Param;
            %
            cd('D:\Unite de Recherche\Projets de recherche\Bobines_nodales\Donnees');
            %[filename, pathname] = uiputfile( {'*.mat'},'Save as .mat');
            filename=sprintf('Data_CIERM_serie_%s_%s',date,Data_Info.SeriesNumber);
            expression = ['save ',filename,' Data_MRI']; %on sauve la variable Data_ROI du workspace dans le fichier
            eval(expression) ;    
            
            clear Data_MRI; clear Data_Instance;

            
            Data_Instance.Data_Image(:,:,:,tabfile(k).inst,1)= double ( DicomRead(tabfile(k).filename)  );
            serie=tabfile(k).serie;
            
         end
        
      end
    
            %%%%%
            Data_Param.NbSlice=tabfile(num_files).inst
            Data_Info.SeriesNumber=num2str(serie);
            %%%%%
            Data_MRI.Data_Instance=Data_Instance;
            Data_MRI.Data_Info=Data_Info;
            Data_MRI.Data_Param=Data_Param;
            %
            cd('D:\Unite de Recherche\Projets de recherche\Bobines_nodales\Donnees');
             filename=sprintf('Data_CIERM_serie_%s_%s',date,Data_Info.SeriesNumber);
            expression = ['save ',filename,' Data_MRI']; %on sauve la variable Data_ROI du workspace dans le fichier
            eval(expression) ;    
            
            clear Data_MRI; clear Data_Instance;

    
end         


%% ensuite pour lire les images il faut executer les commandes suivantes

%% on charge Data MRI  --> Data MRI apparait dans le worspace, disponible
% %% pour traiter.
% cd('C:\Documents and Settings\coussy\Mes documents\Olivier\Thèse\document de thèse Orsay\manips\campagne CIERM septembre 2006\etude en cours matlab\CIERM_matfiles');
% [filename, pathname]=uigetfile({'*.mat'},'Load .mat');
% cd(pathname);
% load(filename);
% %% On recupère les données qui sont dans la structure Data_MRI, en
% %% enlevant le superflu, càd que M n'est plus qu'une matrice 3D, x,y et
% %% nbre de coupe
% Data_MRI;
% M(:,:,:)=Data_MRI.Data_Instance.Data_Image(:,:,1,:,1);