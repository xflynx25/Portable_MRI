function plot_editer_advanced(uncorrected, corrected, scale_param, varargin)
    % generic so can do ksp or img 
    
    % Determine the available range
    x_size = size(uncorrected, 1);
    y_size = size(uncorrected, 2);
    daspect_ratio = x_size / y_size;
    
    % Default ranges
    x_range = 1:x_size;
    y_range = 1:y_size;
    
    % Update optional arguments if provided
    if ~isempty(varargin)
        if length(varargin) >= 2
            x_range = varargin{1};
            y_range = varargin{2};
            daspect_ratio = varargin{3};
        end
    end

    % Create a new figure with a tiled layout
    figure;
    t = tiledlayout(1, 3, 'TileSpacing', 'Compact', 'Padding', 'Compact');
    %sgtitle('Comparison of Uncorrected, Corrected, and Difference Images');

    % Function to plot with optional log scale and colorbar labels
    function plot_with_scale_local(data, title_text, colorbar_label_suffix, scale_param, daspect_ratio)
        prefix = ''; 
        %imagesc(flipud(rot90(abs(data(x_range, y_range)))));

        data = abs(data(x_range, y_range));

        if scale_param == 0
            prefix = 'Absolute '; 
            imagesc(data);
        else 
            if scale_param < 1  
                prefix = 'Clim ';     
                imagesc(data);
                clim([0, scale_param]); %caxis   
            else
                prefix = 'Logarithmic '; 
                logdata = data; 
                for logiter = 1:scale_param
                    logdata = log1p(logdata); 
                end
                imagesc(logdata); 
            end
        end 


        colormap gray; 
        hcb = colorbar; 

        % creating the label 
        colorbar_label = strcat(prefix, colorbar_label_suffix);
        ylabel(hcb, colorbar_label);

        axis equal; 
        axis tight;
        %daspect([1 1 1] ./ [length(y_range) / length(x_range) 1 1]); % Adjust aspect ratio        
        daspect([1 1 1] ./ [daspect_ratio, 1 1]); % Adjust aspect ratio using the provided ratio
        title(title_text);
    end




    % Uncorrected image
    nexttile;
    plot_with_scale_local(uncorrected, 'Primary Uncorrected', '', scale_param, daspect_ratio);

    % Corrected image
    nexttile;

    plot_with_scale_local(corrected, 'Corrected with EDITER', '', scale_param, daspect_ratio);

    % Difference image
    nexttile;
    diff_img = abs(uncorrected(x_range, y_range)) - abs(corrected(x_range, y_range));
    plot_with_scale_local(diff_img, 'Difference Image', ' Difference' ,scale_param, daspect_ratio);

    % Calculate the RMS error, how much error if you don't correct for EMI
    erms = rms(abs(uncorrected(:) - corrected(:)));
    fprintf('RMS Error (EMI Correction): %.4f\n', erms);
    normalized_erms = rms(abs(uncorrected(:) - corrected(:)) / rms(abs(corrected(:))));
    fprintf('Normalized RMS Error (EMI Correction): %.4f\n', normalized_erms);
end
