function [Data] = Lecteur_donnees_dynamiques_codage_mvt( )

%Localisation du répertoire DICOM
[filename, dirname] = uigetfile('*.*','Load Work Directory and clik the first image of the sequence');
cd (dirname);

%%%%%%%%%%%%%%%%%%%%%%%%%
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
         
%         acq=tabfile(indice).acq
%         inst=tabfile(indice).inst
%         serie=tabfile(indice).serie
%         filename=tabfile(indice).filename
        
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
    
    if(k>1)
        index=k-1;
    else
        index=k;
    end
        
    
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
            %serie=tabfile(k).serie;          
                                        
        else
            
            %%%%%
            Data_Param.NbSlice=tabfile(k-1).inst
            Data_Info.SeriesNumber=num2str(serie);
            %%
            Data_MRI.Data_Instance=Data_Instance;
            Data_MRI.Data_Info=Data_Info;
            Data_MRI.Data_Param=Data_Param;
            %%
            
            ExperimentDate=datevec(Data_MRI.Data_Info.FileModDate);
            ExperimentYear=num2str(ExperimentDate(1));
            DateStamp=[ExperimentYear(3:4) num2str(ExperimentDate(2)) ...
                num2str(ExperimentDate(3))];
            filename=['CIERM_' DateStamp '-' Data_MRI.Data_Info.SeriesNumber '_' ...
                Data_MRI.Data_Info.StudyName '.mat'];
            cd('..');
            DirectoryNameList=[]
            Directory=dir;
            DirectoryList={Directory.name};
            for l=1:size(DirectoryList,2)
                DirecName=DirectoryList(l);
                DirecName(1)=[];
                DirecName(end)=[];
                DirectoryNameList=[DirectoryNameList str2num(DirecName)];
            end
            [CreationSuccess,AlreadyExists,messid] = mkdir('..',DateStamp);
            if messid==MATLAB:MKDIR:DirectoryExists
                warning(AlreadyExists);
            else if CreationSuccess==1
            save('filename',Data_MRI); %on sauve la variable Data_MRI du workspace dans le fichier
            
            clear Data_MRI; clear Data_Instance;

            
            Data_Instance.Data_Image(:,:,:,tabfile(k).inst,1)= double ( DicomRead(tabfile(k).filename)  );
            serie=tabfile(k).serie;
            
         end
        
      end
    
    %%%%%
    Data_Param.NbSlice=tabfile(num_files).inst
  
    %%%%%
    index=num_files;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%--> DataMRI.Data_Info
    Data_Info.FileName=DirName;
    Data_Info.StudyName=Dicom_Info(index).SeriesDescription;
    Data_Info.SeriesNumber=num2str(Dicom_Info(index).SeriesNumber);
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
  
   
            
            
            
            
            Data_MRI.Data_Instance=Data_Instance;
            Data_MRI.Data_Info=Data_Info;
            Data_MRI.Data_Param=Data_Param;
            %
            cd('..');
            filename=sprintf('Data_CIERM_serie_%s_%s',date,Data_Info.SeriesNumber);
            expression = ['save ',filename,' Data_MRI']; %on sauve la variable Data_ROI du workspace dans le fichier
            eval(expression) ;    
            
            clear Data_MRI; clear Data_Instance;

    
