function new_preprocesstnt(raw_data_path, outpath, Nc, Necho, Nro, Nbuffer, N2d, Nrepeats, Nfe, Primary_Coil_Number)
                                
    % Read Tecmag data
    [Ms1, ~, ~] = Read_Tecmag(raw_data_path);
    
    inshape = size(Ms1)

    product_inshape = prod(inshape)
    product_proposedshape = Nc * Necho * Nro * N2d * Nrepeats * (Nfe+1)

    % Necho and Nc could be reversed 
    unpacked = reshape(Ms1, Nc, Necho, Nro, N2d, Nrepeats, Nfe+1); 
    unpackedshape = size(unpacked)

    temp = permute(unpacked,[ 3 6 2 1 4 5]);
    temp = temp(1:Nro-Nbuffer, 2:end, :, :, :, :); % clean up the dead trial and buffer filter correct
    outshape = size(temp)

    % Initialize a structure to store the variables
    data_struct = struct();
    data_struct.('datafft_combined') = temp; 

    % Save the structure to the output file
    save(outpath, '-struct', 'data_struct');
    disp(['Processed data saved to ', outpath]);
end
