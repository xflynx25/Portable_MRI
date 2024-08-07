function [data] = phaseslice_3d_ifft(coil_data)
    data = ifftshift(ifftn(ifftshift(coil_data)));
end