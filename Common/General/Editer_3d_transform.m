function [corrected_img_3d, corrected_ksp_3d] = Editer_3d_transform(combined_data, slice_type)
    % this deals with 3d and multi-detector, returns the transformed data
    % PE, FE, Slice, Detector
    % slice types
    % 'cartesian' - build the kernels slice by slice in 2d space
    % 'phaseslice' - build the kernels in 3d space
    % 'phaseslice_old' - how clarissa does it with cartesian even though
    % collected in phaseslice

    size_cd = size(combined_data);
    finish_sizes = size_cd(1:end-1);
    corrected_img_3d = zeros(finish_sizes);
    corrected_ksp_3d = zeros(finish_sizes);

    if strcmp(slice_type, 'cartesian')
        for slice = 1:size(combined_data, 3)
            slice_data = squeeze(combined_data(:, :, slice, :)); 
            [corrected_img, corrected_ksp] = Editer_2d_transform(slice_data);
            corrected_img_3d(:, :, slice) = corrected_img; 
            corrected_ksp_3d(:, :, slice) = corrected_ksp; 
        end
    end

    if strcmp(slice_type, 'phaseslice') %main difference is to ifft image rather than slices
        for slice = 1:size(combined_data, 3)
            slice_data = squeeze(combined_data(:, :, slice, :)); 
            [~, corrected_ksp] = Editer_2d_transform(slice_data);
            %corrected_img_3d(:, :, slice) = corrected_img; 
            corrected_ksp_3d(:, :, slice) = corrected_ksp; 
        end
        corrected_img_3d = phaseslice_3d_ifft(corrected_ksp_3d);
    end

    if strcmp(slice_type, 'phaseslice_old') 
        % loop through each coil, and ifft over the 3rd (slice select)
        % direction, and reconcat
        for coil = 1:size(combined_data, 4)
            this_coil = combined_data(:, :, :, coil);
            combined_data(:, :, :, coil) = ifftshift(ifft(ifftshift(this_coil,3),[],3),3);
        end

        % same as cartesian
        for slice = 1:size(combined_data, 3)
            slice_data = squeeze(combined_data(:, :, slice, :)); 
            [corrected_img, corrected_ksp] = Editer_2d_transform(slice_data);
            corrected_img_3d(:, :, slice) = corrected_img; 
            corrected_ksp_3d(:, :, slice) = corrected_ksp; 
        end
    end
end
