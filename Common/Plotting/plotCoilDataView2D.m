function plotCoilDataView2D(cd, IMAGE_SCALE, KSPACE_SCALE)
    % Coil View Plot Function, baseline viewer
    % cd: coil data (3D matrix: X x Y x coils)
    % num_coils: number of coils
    % IMAGE_SCALE: scaling factor for image space visualization
    % KSPACE_SCALE: scaling factor for k-space visualization

    num_coils = size(cd, ndims(cd));
    
    figure;
    set(gcf, 'Name', '4 Coil View', 'NumberTitle', 'off');
    
    % Plot image space for each coil
    for i = 1:num_coils
        subplot(2, num_coils, i);
        imgspace = ifftshift(ifft2(ifftshift(cd(:, :, i))));
        plot_with_scale(abs(imgspace), sprintf('Image coil%d', i), true, IMAGE_SCALE);
    end
    
    % Plot k-space for each coil
    for i = 1:num_coils
        subplot(2, num_coils, num_coils + i);
        plot_with_scale(abs(cd(:, :, i)), sprintf('ksp coil%d', i), true, KSPACE_SCALE);
    end
end
