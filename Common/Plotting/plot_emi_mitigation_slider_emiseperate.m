function plot_emi_mitigation_slider_emiseperate(combined_data, N, slice_type, square_plot, scale_param)
    % Set default values for square_plot and scale_param if not provided
    if nargin < 3
        slice_type = 'cartesian';
    end
    if nargin < 4
        square_plot = false;
    end
    if nargin < 5
        scale_param = 0;
    end

    % Adjust N if it doesn't work
    N = min(N, size(combined_data, 3) - 1); 

    % Extract primary and EMI data from combined data
    primary_data = combined_data(:, :, :, 1);

    initialSlice = 1;

    % Need to get the values for IFFTs for primary, EMI, and the removed EMI will be the sum of detectors
    data2d = abs(do_3d_ifft(primary_data, slice_type));

    num_detectors = size(combined_data, 4);
    emi_realspace = zeros(size(combined_data(:,:,:,2:num_detectors)));
    for detector = 2:num_detectors
        detector_data = combined_data(:, :, :, detector);
        emi_transformed = abs(cartesian_3d_ifft(detector_data)); 
        emi_realspace(:,:,:, detector - 1) = emi_transformed; 
    end
    data2dEMI = emi_realspace;

    % Assuming Editer_3d_transform is defined elsewhere and works correctly
    [I3D_Editer, corrected_ksp_3d] = Editer_3d_transform(combined_data, slice_type); 
    I3D_Editer = abs(I3D_Editer);

    % Create figure and axes
    title = sprintf('MRI Image Slice Viewer - Scale Param: %g', scale_param);
    ax = figure('Name', title, 'NumberTitle', 'on');
    slider = uicontrol('Parent', ax, 'Style', 'slider', 'Units', 'normalized', ...
                       'Position', [0.1, 0, 0.8, 0.05], 'Value', initialSlice, ...
                       'min', 1, 'max', size(I3D_Editer, 3) - N + 1, ...
                       'SliderStep', [1/(size(I3D_Editer, 3) - N) 1/(size(I3D_Editer, 3) - N)], ...
                       'Callback', @(src, event) updateSlices(round(src.Value), N, ax, data2d, I3D_Editer, data2dEMI, square_plot, scale_param));

    % Initial display
    updateSlices(initialSlice, N, ax, data2d, I3D_Editer, data2dEMI, square_plot, scale_param);


    function updateSlices(startSlice, numSlices, fig, data2d, I3D_Editer, data2dEMI, square_plot, scale_param)
        shouldTranspose = true;  % Set to true to transpose images, false to keep original orientation

        % Helper function to conditionally transpose image data
        function data = adjustImage(data)
            if shouldTranspose
                data = permute(data, [2 1]);  % Swap the first and second dimensions
            end
        end

        % Determine the grid dimensions based on the number of plots
        pics = 3 + size(data2dEMI, 4); 
        totalPlots = numSlices * pics; % Total number of plots

        % Calculate number of rows and columns
        numCols = ceil(sqrt(totalPlots));
        numRows = ceil(totalPlots / numCols);

        for jj = 0:numSlices-1
            idx = startSlice + jj;
            
            % Without EDITER
            subplot(numRows, numCols, 1 + jj * pics, 'Parent', fig);
            plot_with_scale(adjustImage(data2d(:, :, idx)), sprintf('Slice %d: Without EDITER', idx), square_plot, scale_param);

            % With EDITER
            subplot(numRows, numCols, 2 + jj * pics, 'Parent', fig);
            plot_with_scale(adjustImage(I3D_Editer(:, :, idx)), sprintf('Slice %d: With EDITER', idx), square_plot, scale_param);

            % Difference
            subplot(numRows, numCols, 3 + jj * pics, 'Parent', fig);
            plot_with_scale(adjustImage(abs(data2d(:, :, idx) - I3D_Editer(:, :, idx))), sprintf('Slice %d: Difference', idx), square_plot, scale_param);

            % EMI images
            for detect = 1:pics-3
                subplot(numRows, numCols, 3 + detect + jj * pics, 'Parent', fig);
                plot_with_scale(adjustImage(data2dEMI(:, :, idx, detect)), sprintf('Slice %d: EMI %d Image', idx, detect), square_plot, scale_param);
            end
        end
        
    end
end