function read_and_preprocess_tnt(raw_data_path, outpath, Nc, Necho, Nro, Nbuffer, N2d, Nrepeats, Primary_Coil_Number)
                                
    % Read Tecmag data
    [Ms1, ~, ~] = Read_Tecmag(raw_data_path);
    
    size(Ms1)
 

    % Reshape and reorder data
    % Navg will be in the 2d dimension, should go to the end as if 4d
    temp3 = reshape(Ms1, Nro, Necho * Nc, N2d, Nrepeats, '');
    temp = permute(temp3,[ 1 4 2 3]);   %% index 1 is coil #, 2 is RO, 3 is PE, 4 is average #

    %Ms_reorder_pos = tntreshape(Ms1, Nro, Necho * Nc); 
    %size(Ms_reorder_pos)
    %temp = permute(Ms_reorder_pos, [2, 3, 1]);
    size(temp)
    temp = temp(1:Nro-Nbuffer, :, :, :); 

    % Initialize a structure to store the variables
    data_struct = struct();

    for nc = 1:Nc
        ksp_single_coil = temp(:, 2:end, (nc-1)*Necho + 1:nc*Necho, :); %first one is a dud
        varname = sprintf('ksp_noisedata_ch%d_3D', nc);
        data_struct.(varname) = ksp_single_coil; % Dynamically create field in the structure
    end

    % Save the structure to the output file
    save(outpath, '-struct', 'data_struct');

    % Process 
    primary_name = sprintf('ksp_noisedata_ch%d_3D', Primary_Coil_Number);
    Format_MatFile_For_Editor(outpath, primary_name);

end
