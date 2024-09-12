function polygonroi_data = get_polygonroi_data(image_data)
    % Helper function to allow user to draw an ROI on the image and extract the corresponding data
    
    figure;
    imagesc(abs(image_data)); colormap gray;
    title(sprintf('2D Slice'));
    colorbar;
    disp('Select polygon region for further compute');

    % Let the user draw a polygon ROI
    h = drawpolygon();  % User draws the region of interest
    
    % Create a binary mask from the ROI
    mask = createMask(h);
    
    % Extract the pixel values inside the ROI
    polygonroi_data = image_data(mask);  % Returns a vector of the selected ROI values


    %hsig = imrect(gca);
    %polygonroi_data = round(getPosition(hsig));

end
