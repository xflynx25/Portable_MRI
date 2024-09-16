function [SNR] = calculate_snr_saving2d(coil_data, use_saved_coords)

    rootDir = evalin('base', 'rootDir');
    coords_filename = fullfile(rootDir, 'Common/General/SNR/snr_coords.mat');

    % Perform FFT for visuals and selection
    %I3Dfid = ifftshift(ifft2(ifftshift((coil_data)))); 
    I = abs(coil_data);%abs(I3Dfid);


    % Load saved coordinates if needed
    if use_saved_coords
        [signal_coords, noise_coords] = load_coords(coords_filename);
        if isempty(signal_coords) || isempty(noise_coords)
            error('Saved coordinates not found. Please select new regions and save them.');
        end
    else
        figure; % Ensure a new figure is created
        imagesc(I); colormap gray;
        title(sprintf('2D Slice'));
        colorbar;

        % Select signal region for SNR calculation
        disp('Select signal region for SNR calculation');
        hsig = imrect(gca);
        signal_coords = round(getPosition(hsig));

        % Select noise region for SNR calculation
        disp('Select noise region for SNR calculation');
        hnoise = imrect(gca);
        setColor(hnoise, 'red');
        noise_coords = round(getPosition(hnoise));

        delete(hsig); delete(hnoise);

        % Save the coordinates
        save_coords(signal_coords, noise_coords, coords_filename);
    end

    % Calculate SNR
    sig = mean(mean(I(signal_coords(2):signal_coords(2)+signal_coords(4), signal_coords(1):signal_coords(1)+signal_coords(3))));
    noisevec = I(noise_coords(2):noise_coords(2)+noise_coords(4), noise_coords(1):noise_coords(1)+noise_coords(3));
    noise = std(noisevec(:));

    SNR = sig / noise;
    RSD = 100 / SNR; 
    %disp(['sig=', num2str(sig), ', noise=', num2str(noise), ', SNR=', num2str(SNR), ' RSD=', num2str(RSD), '%']);
end

function [signal_coords, noise_coords] = load_coords(filename)
    if exist(filename, 'file')
        data = load(filename);
        signal_coords = data.signal_coords;
        noise_coords = data.noise_coords;
    else
        signal_coords = [];
        noise_coords = [];
    end
end

function save_coords(signal_coords, noise_coords, filename)
    save(filename, 'signal_coords', 'noise_coords');
end