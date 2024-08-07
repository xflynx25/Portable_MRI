function plot_simple_editer(primary_coil, corrected_img, varargin)

    % setting plot parameters
    x_range = size(primary_coil, 1); 
    y_range = size(primary_coil, 2); 
    
    % Update optional arguments if provided
    if ~isempty(varargin) && length(varargin) >= 2
        x_range = varargin{1};
        y_range = varargin{2};
    end

    figure;
    t = tiledlayout(1,3,'TileSpacing','Compact','Padding','Compact');
    nexttile
    uncorr = ifftshift(ifftn(ifftshift(primary_coil)));

    imagesc(flipud(rot90(abs(uncorr(x_range,y_range)))));  colormap gray; colorbar; %caxis([0 4e5]);
    axis equal; 
    axis tight;
    title([' primary uncorrected']);
    nexttile
    imagesc(flipud(rot90(abs(corrected_img(x_range,y_range))))); colormap gray; colorbar; %caxis([0 4e5]);
    axis equal; 
    axis tight;  
    title([' corrected with EDITER' ]); 
    nexttile
    imagesc(flipud(rot90(abs(uncorr(x_range,y_range))))-flipud(rot90(abs(corrected_img(x_range,y_range)))));
    colormap gray; colorbar; %caxis([0 4e5]);
    axis equal; 
    axis tight; 
    title([' difference image' ]);
    %set(gcf,'position',[378 555 1010 265]);

    disp('finihs plot')
    
    erms = rms(abs(uncorr(:)-corrected_img(:)))
end 