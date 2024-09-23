Showme=0;
Writeme=0;
Sampleme=0;

Image_selection=[1582:1741];
mRep=ceil(sqrt(size(Image_selection,2)));
Petit_Nfps=7.1;%Nombre d'images par seconde
Petit_film=avifile('Cartes_nodales_1000mA','compression','None','fps',Petit_Nfps);
figure;
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
    imshow(squeeze(double(M(1:224,50:222,1,1))/max(double(M(:)))));
    colormap(jet)
    colorbar
    title(['Plan n°' num2str(k-Image_selection(1))],'FontName','Times new roman','FontSize',13,'FontWeight','demi');
    F = getframe(gca);
    Petit_film = addframe(Petit_film,F);
end
Petit_film = close(Petit_film);
