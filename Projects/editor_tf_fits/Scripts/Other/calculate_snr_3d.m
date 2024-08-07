function calculate_snr_3d(coil_data, snrslice)
    % Perform FFT for visuals
    %I3Dfid = ifftshift(ifftn(ifftshift(coil_data)));
    I3Dfid = cartesian_3d_ifft(coil_data); 

    figure; % Ensure a new figure is created


    I = (abs(I3Dfid(:, :, snrslice)));
    imagesc(I); colormap gray;
    title(sprintf('2D Slice at Z = %d', snrslice));
    colorbar;

    % Select signal region for SNR calculation
    disp('Select signal region for SNR calculation');
    hsig = imrect(gca);
    hcoordsig = round(getPosition(hsig));
    sig = mean(mean(I(hcoordsig(2):hcoordsig(2)+hcoordsig(4), hcoordsig(1):hcoordsig(1)+hcoordsig(3))));
    %sigvec = I(hcoordsig(2):hcoordsig(2)+hcoordsig(4), hcoordsig(1):hcoordsig(1)+hcoordsig(3));
    %sig = std(sigvec(:));

    % Select noise region for SNR calculation
    disp('Select noise region for SNR calculation');
    hnoise = imrect(gca);
    setColor(hnoise, 'red');
    hcoordnoise = round(getPosition(hnoise));
    noisevec = I(hcoordnoise(2):hcoordnoise(2)+hcoordnoise(4), hcoordnoise(1):hcoordnoise(1)+hcoordnoise(3));
    noise = std(noisevec(:));

    delete(hsig); delete(hnoise);

    SNR = sig/noise;
    RSD = 100/SNR; 
    disp(['sig=', num2str(sig), ', noise=', num2str(noise), ', SNR=', num2str(SNR), ' RSD=', num2str(RSD), '%']);
end
