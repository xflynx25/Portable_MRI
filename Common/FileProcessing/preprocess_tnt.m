function preprocess_tnt(raw_data_path, outpath, Nc, Necho, Nro, Nbuffer, N2d, Nrepeats, Nfe, options)
                                
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

    
    SmartSaveMatData(temp, outpath); % creates folders if necessary 
    DefaultVisualization(temp, options);
end
