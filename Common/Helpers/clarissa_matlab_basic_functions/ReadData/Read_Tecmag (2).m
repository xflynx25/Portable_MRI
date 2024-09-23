function [Ms,Header,filename]=Read_Tecmag(filename,dsize)
    Ms=[];
    Header=[];

    if (nargin<1)
        [filename,path]=uigetfile('*.tnt');
        filename=strcat(path,filename);
    end
     Header=Read_Tecmag_Header(filename);
     ds=Header.acq_points;
     ss=Header.actual_npts;
    if (nargin<2)
        ss(1)=ss(1)/ds(1);
        dsize=[ds(1) ss];
    end
        
% lecture des données
offset=1056;
   Ms=Read_Raw_Field(filename,offset,[2,dsize],'float','l');
   Ms=Ms(1,:,:,:,:)+i*Ms(2,:,:,:,:);
   Ms=squeeze(Ms);