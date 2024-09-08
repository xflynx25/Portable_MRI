function plot_3d_reconstruction_slices(coil_img_data, square_plot, scale_param)
    % Set default values for square_plot and scale_param if not provided
    if nargin < 2
        square_plot = false;
    end
    if nargin < 3
        scale_param = 0;
    end

    % Perform FFT for 3D visuals
    I3Dfid = coil_img_data;

    % Create a figure for the 3D visualization
    h = figure;
    
    % Generate 3D visualization
    x = 1:size(I3Dfid, 1);
    y = 1:size(I3Dfid, 2);
    z = 1:size(I3Dfid, 3);
    
    % Create the 3D volume data
    [X, Y, Z] = meshgrid(y, x, z); % Note the order of dimensions
    V = abs(I3Dfid);
    
    % Define slice positions, ensuring they are within the bounds
    xslice = round(size(I3Dfid, 1) / 2);
    yslice = round(size(I3Dfid, 2) / 2);
    zslice = round(size(I3Dfid, 3) / 2);
    
    % Plot 3 slices from the 3D volume
    slice(X, Y, Z, V, yslice, xslice, zslice);
    
    % Apply colormap and shading
    colormap gray;
    shading interp;
    
    % Apply scale parameter for caxis and/or logarithmic scaling
    apply_scale(V, scale_param);
    
    % Apply square plot if requested
    if square_plot
        axis equal;
    end
    
    % Add title and labels
    title('3D Visualization of the Volume Data');
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    colorbar;
end

function apply_scale(data, scale_param)
    if scale_param == 0
        % Do nothing, use default scale
    elseif scale_param < 1
        clim([0, scale_param]);
    else
        logdata = data;
        for logiter = 1:scale_param
            logdata = log1p(logdata);
        end
        clim([min(logdata(:)), max(logdata(:))]);
    end
end
