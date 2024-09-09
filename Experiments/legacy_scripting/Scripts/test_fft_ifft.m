function test_fft_ifft(gksp)
    % Compute FFT and IFFT images
    fft_img = fftshift(fftn(fftshift(gksp)));
    ifft_img = ifftshift(ifftn(ifftshift(gksp)));

    % Display the original, FFT, and IFFT images
    figure;
    
    % Original gksp data
    subplot(1, 3, 1);
    imagesc(abs(gksp));
    colormap gray;
    colorbar;
    title('Original gksp');

    % FFT image
    subplot(1, 3, 2);
    imagesc(abs(fft_img));
    colormap gray;
    colorbar;
    title('FFT Image');

    % IFFT image
    subplot(1, 3, 3);
    imagesc(abs(ifft_img));
    colormap gray;
    colorbar;
    title('IFFT Image');
    
    disp('Finished displaying original, FFT, and IFFT images');
end
