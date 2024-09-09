function xfft = shiftyfft(ksp)
    xfft = fftshift(fft2(fftshift(ksp)));
end