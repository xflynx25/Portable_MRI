% typically used right after processing to check the work 
% 5 plots, ksp and img for both mosaics (if 3d) and classical EDITER, and
% lastly the coil view, 2x4
function DefaultVisualization(processed_data, options)
    % Default visualization options
    defaultOptions = struct(...
        'visualize', 0, ...
        'SLICE', 1, ...
        'REPEAT', 1, ...
        'IMAGE_SCALE', 2, ...
        'KSPACE_SCALE', 1, ...
        'CALIBRATION', 0);

    if nargin < 2 || isempty(options)
        options = defaultOptions;
    else
        % Merge the passed options with the default options
        options = setstructfields(defaultOptions, options);
    end

    % Visualizations for sanity check and debugging
    if options.visualize == 1

        % Extract options
        SLICE = options.SLICE; 
        REPEAT = options.REPEAT; 
        IMAGE_SCALE = options.IMAGE_SCALE; 
        KSPACE_SCALE = options.KSPACE_SCALE; 
        CALIBRATION = options.CALIBRATION;

        % Determine dimension 5 based on calibration
        if CALIBRATION 
            dim5 = 1; 
        else
            dim5 = size(processed_data, 5); 
        end

        % Preprocess data
        cd = squeeze(processed_data(:, :, SLICE, REPEAT, dim5, :));
        num_coils = size(cd, 3); 

        % Visualization: K-space and image space
        disp('Plotting initial vis...');

        % Mosaic K-space
        dim3 = size(processed_data, 3);
        disp('Plotting mosaic ksp');
        primary = squeeze(processed_data(:, :, :, REPEAT, dim5, 1));
        mosaic(abs(primary), ceil(sqrt(dim3)), ceil(sqrt(dim3)));
        set(gcf, 'Name', 'Mosaic 3D KSP', 'NumberTitle', 'off');

        % Mosaic Image Space
        disp('Plotting mosaic img space');
        img_space = cartesian_3d_ifft(primary);
        mosaic(abs(img_space), ceil(sqrt(dim3)), ceil(sqrt(dim3)));
        set(gcf, 'Name', 'Mosaic 3D Image Space', 'NumberTitle', 'off');

        % Visualizing Editer
        Editer_2d_transform(cd, 1); 
        set(gcf, 'Name', 'EDITER Image Space', 'NumberTitle', 'off');

        % Coil View
        plotCoilDataView2D(cd, IMAGE_SCALE, KSPACE_SCALE)
    end
end
