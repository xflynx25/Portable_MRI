Showme=0;
Writeme=1;
Sampleme=0;

Image_selection=[1];
mRep=ceil(sqrt(size(Image_selection,2)));
if Showme==1
    figure('name','Images sélectionnées');
end
for k=Image_selection
    if k<10
        Dicom_filename=['IM_000' num2str(k)];
    elseif k<100
        Dicom_filename=['IM_00' num2str(k)];
    elseif k<1000
        Dicom_filename=['IM_0' num2str(k)];
    else
        Dicom_filename=['IM_' num2str(k)];
    end
    M = dicomread(Dicom_filename);
    N_images=size(M,4);
    if Sampleme==1
        N_images=3;
    end
    if Showme==1
        subplot(mRep,mRep,k-Image_selection(1)+1)
        imshow(squeeze(double(M(:,:,1,1))/max(double(M(:)))));
    end
    %title(num2str(k));
    if Showme==1
        for n_image=1:N_images
            figure('name',['Image n°' num2str(n_image)])
            imshow(squeeze(double(M(:,:,1,n_image))/max(double(M(:)))));
        end
    end

    if Writeme==1
        for n_image=1:N_images
            File_number=num2str(n_image);
            if size(File_number,2)<2
                File_number=[num2str(0) num2str(0) num2str(0) num2str(n_image)];
            elseif size(File_number,2)<3
                File_number=[num2str(0) num2str(0) num2str(n_image)];
            elseif size(File_number,2)<4
                File_number=[num2str(0) num2str(n_image)];
            end
            Tif_filename=['\Trachee_saggitale_tif\Trachee_coupe_saggitale_' File_number '.tif'];
            imwrite(squeeze(double(M(:,:,1,n_image))/max(double(M(:)))),Tif_filename);
        end
    end
end