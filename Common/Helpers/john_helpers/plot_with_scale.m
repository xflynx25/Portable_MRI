% scale_param serves as caxis cutoff param if 0-1
function plot_with_scale(data, title_text, square_plot, scale_param, daspect_ratio)
    colormap gray; 
    plotdata = data; 
    if scale_param ~= 0 
        if scale_param < 1      
            clim([0, scale_param]); %caxis   
        else
            logdata = data; 
            for logiter = 1:scale_param
                logdata = log1p(logdata); 
            end
            plotdata = logdata; 
        end
    end 
    imagesc((plotdata)); % you can rotate it here

    if square_plot

        x_size = size(data, 1);
        y_size = size(data, 2);
        daspect([1 1 1] ./ [x_size / y_size 1 1]); % Adjust aspect ratio        
        %daspect([1 1 1] ./ [8 1 1]);   
    end
    %axis image; 
    %daspect([1 1 1] ./ [4 1 1]);  
    title(title_text);
end