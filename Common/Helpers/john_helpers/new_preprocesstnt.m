function new_preprocesstnt(raw_data_path, outpath, Nc, Necho, Nro, Nbuffer, N2d, Nrepeats, Nfe, visualize)
                                
    % Read Tecmag data
    [Ms1, ~, ~] = Read_Tecmag(raw_data_path);
    inshape = size(Ms1)
    product_inshape = prod(inshape)
    product_proposedshape = Nc * Necho * Nro * N2d * Nrepeats * (Nfe+1)

    close all; 
    %plot_with_scale(abs(Ms1(:, :, 1, 1)), 'yar tets', true, 2)

    % reshape and permute
    midstage = reshape(Ms1, Nro, Necho*Nc, N2d, Nfe+1, Nrepeats); 
    unpacked = reshape(midstage, Nro, Necho, Nc, N2d, Nfe+1, Nrepeats); %proper way to get the 3d
    %unpacked = reshape(Ms1, Nro, Nc, Necho, N2d, Nrepeats, ''); 
    unpackedshape = size(unpacked)
    temp = permute(unpacked,[ 1 5 2 6 4 3]);


    temp = temp(1:Nro-Nbuffer, 2:end, :, :, :, :); % clean up the dead trial and buffer filter correct
    outshape = size(temp)

    % bump to 3d if necessary
    if size(temp, 3) == 1
        temp = cat(3, temp, temp);  % Duplicate the data along the third dimension
    end
    outshape = size(temp)

    

    % Initialize a structure to store the variables
    data_struct = struct();
    data_struct.('datafft_combined') = temp; 

    % Save the structure to the output file
    save(outpath, '-struct', 'data_struct');
    disp(['Processed data saved to ', outpath]);


    % visualizations for sanity check and debugging
    if visualize == 1  

        % preprocessing
        SLICE = 1; 
        AVERAGE = 1; 
        IMAGE_SCALE = 2; 
        KSPACE_SCALE = 1; 
        CALIBRATION = 0;
        if CALIBRATION 
            dim5 = 1; 
        else
            dim5 = size(temp, 5); 
        end
        cd = squeeze(temp(:, :, SLICE, AVERAGE, dim5, :));
        num_coils = size(cd, 3); 

        % visualizing ksp and image
        disp('Plotting initial vis...');
        figure;
        for i = 1:num_coils
            subplot(2, num_coils, i);
            imgspace = ifftshift(ifft2(ifftshift(cd(:, :, i))));
            plot_with_scale(abs(imgspace), sprintf('Image coil%d', i), true, IMAGE_SCALE);
        end 
        for i = 1:num_coils 
            subplot(2, num_coils, 4 + i);
            plot_with_scale(abs(cd(:, :, i)), sprintf('ksp coil%d', i), true, KSPACE_SCALE);
        end 

        % visualizing editer
        Editer_2d_transform(cd, 1); 

        % visualizing mosaic ksp (3rd dim slices of primary)
        dim3 = size(temp, 3);
        disp('Plotting mosaic ksp');
        primary = squeeze(temp(:, :, :, AVERAGE, dim5, 1));
        mosaic(abs(primary), ceil(sqrt(dim3)), ceil(sqrt(dim3)));

        % visualizing mosaic img space (3rd dim slices of primary)
        disp('Plotting mosaic img space');
        %img_space = phaseslice_3d_ifft(primary);
        img_space = cartesian_3d_ifft(primary);
        mosaic(abs(img_space), ceil(sqrt(dim3)), ceil(sqrt(dim3)));
    end
end
