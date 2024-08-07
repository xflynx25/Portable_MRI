function [data] = cartesian_3d_ifft(coil_data)
    data = zeros(size(coil_data));
    for slice = 1:size(coil_data, 3)
        data(:, :, slice) = ifftshift(ifft2(ifftshift(coil_data(:, :, slice))));
    end    
end