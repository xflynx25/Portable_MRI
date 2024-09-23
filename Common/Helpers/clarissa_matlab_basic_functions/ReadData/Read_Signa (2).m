function [Ms,Fid,Header]=Read_Signa(filename)
    Ms=[];
    Fid=[];
    Header=[];
    multicoupes=0;
    if (nargin==0)
        [filename,path]=uigetfile('*.raw');
        filename=strcat(path,filename);
    end

    s=dir(filename);
    si=size(s);
    if si(1,1)==1
        
    Header=Read_Signa_Header(filename);

    if size(Header)~=[0 0]
        Nx=Header.rdb_hdr_frame_size;
        Ny=Header.rdb_hdr_nframes;
        data_size=Header.rdb_hdr_point_size;
        nslices=Header.slquant;
        npasses=Header.rdb_hdr_npasses;
        psdname=Header.psdname;
        user7=Header.user7;
        user10=Header.user10;
        user14=Header.user14;
    
        Nz=nslices;

    
    % detection des multi-coupes en plusieurs fichiers
        [dname,fname,ename]=fileparts(filename);
    
    %nslices ; nb de coupes // npasses ; nb de passages
        if nslices==npasses % alors nslices fichiers
            fname=double(fname);
            fsiz=size(fname);
            num_image=eval(char(fname((fsiz(1,2)-1):1:fsiz(1,2))));
            fname=char(fname(1:(fsiz(1,2)-3)));
            Nz=1;
        %presence des npasses images?
            f=dir([dname fname '_*.raw' ]);
            f=char(f.name);
            if max(size(f))~=npasses;
                fname=filename;
                max_im=1
                multi_coupes=0;
            else
                fname=f;
                max_im=npasses;
                multi_coupes=1;
            end
        else
            multi_coupes=0;
            max_im=1
            fname=filename
        end
       
    % si T2 entrelace
        if psdname(1,1:11)=='CM_He2FLASH'
            Nz=Nz*2;
        end

        for num_im=1:max_im % on peut lire les donnees
       % fid 1 et 2?????
            if (multi_coupes==0)
                noFID1=0;
            else
                if(num_im==1)
                    noFID1=0;
                else
                    noFID1=1;
                end
            end
        % fid 3?????
            if (multi_coupes==1)
                if (num_im~=nslices)
                    noFID3=1;
                else
                    noFID3=0;
                end
            else
                noFID3=0;
            end

        
        
        % lecture de la fid
            offset=39940;
            if((user10>0)&(noFID1==0))
                fid0=Read_Raw_Field(fname(num_im,:),offset,[2,256,2],'long','b');
                fid=fid0(1,:,:)+j*fid0(2,:,:);
                fid=reshape(fid,256,2);
                offset=offset+2*256*data_size*2;
            end
        
% lecture des données
%    M0=Read_Raw_Field(fname(num_im).name,offset,[2,Nx,Ny,Nz],'long','b');
            M0=Read_Raw_Field(fname(num_im,:),offset,[2,Nx,Ny,Nz],'long','b');
            size(M0);
            
% lecture fid 3
            offset=39940+Nx*Ny*Nz*data_size*2;%+2*256*data_size*2;
            if((user10>0)&(noFID3==0))
                fid0=Read_Raw_Field(fname(num_im,:).name,offset,[2,256],'long','b');
                fid=fid0(1,:)+j*fid0(2,:);
                fid_finale=reshape(fid,256);
                fid=[fid,fid_finale];
            end

%reorganisation des données
            if max(size(M0))~=0
                M0=M0(1,:,:,:)+j*M0(2,:,:,:);
                M0=reshape(M0,Nx,Nz,Ny);
                M0=permute(M0,[1,3,2]);
        
% gestion de la lecture des flash cpmg flash
                if strcmp(psdname(:,1:14),'CM_HeFLASHCPMG')==1
                    N180=Read_Raw_Field(fname(num_im,:),offset,[2,256,(user14-1)],'long','b');
                    N180=N180(1,:,:)+j*N180(2,:,:);
                    N180=reshape(N180x,256,user14-1);
                    fsiz=size(fid);
                    fid=[fid(:) N180(:)];
                    fid=reshape(fid,256,fsiz(1,2)+user14-1);
                    offset=offset  +(user14-1)*256*data_size*2;
                    M1=Read_Raw_Field(fname(num_im,:),offset,[2,Nx,Ny,Nz],'long','b');
                    if max(size(M1))~=0
                        M1=M1(1,:,:,:)+j*M1(2,:,:,:);
                        M1=reshape(M1,Nx,Nz,Ny);
                        M1=permute(M1,[1,3,2]);
    
                        M0=[M0(:);M1(:)];
                        Nz=2*Nz;
                    end
                end

% matrice complexe
                M0=reshape(M0,Nx,Ny,Nz);


%flip alterné pour toutes les séquences sauf PR
                if strcmp(psdname(1,1:7),'CM_HePR')~=1
                    M0(:,2:2:Ny,:)=-M0(:,2:2:Ny,:);
                end


%codage centre
                msi=size(M0);
                if user7==2% codage centré
                    if Nz==1
                        M01=M0(:,:);
                        M01(:,(msi(1,2)/2):-1:1)=M0(:,1:2:msi(1,2));
                        M01(:,(msi(1,2)/2+1):1:msi(1,2))=M0(:,2:2:msi(1,2));
                        M0=M01;
                    else
                        M01=M0(:,:,:);
                        M01(:,(msi(1,2)/2):-1:1,:)=M0(:,1:2:msi(1,2),:);
                        M01(:,(msi(1,2)/2+1):1:msi(1,2),:)=M0(:,2:2:msi(1,2),:);
                        M0=M01;
                    end
                end
                Ms=[Ms(:);M0(:)];
            else
                Ms=[];
            end
        end
    end

    if max(size(multi_coupes))==0
        M=[];
        fid=[];
        header=[];
    else
        if max(size(multi_coupes))>0
            if multi_coupes==1
            if strcmp(psdname(1,1:11),'CM_He2FLASH')==1
                Ms=reshape(Ms,Nx,Ny,2*npasses);
            else
                Ms=reshape(Ms,Nx,Ny,npasses);
            end
            else
            Ms=reshape(Ms,Nx,Ny,Nz);
            end
        else
            Ms=reshape(Ms,Nx,Ny,Nz);
        end
    end
end
