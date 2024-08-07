function [img_data] = do_3d_ifft(coil_data, slice_type)
    if strcmp(slice_type, 'cartesian')
        img_data = cartesian_3d_ifft(coil_data); 
    else
        img_data = phaseslice_3d_ifft(coil_data);
    end    
end