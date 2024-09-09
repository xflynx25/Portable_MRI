% dimension 5 should be processed to keep the proper number of dimensions
% then you could put in a lambda func to deal with calibration, or
% averaging, or just a single row
% so this has become a super powerful thing which you can use to just get
% the info here, saving lines elsewhere 
function [raw1, img1, raw2, img2] = repeat_evaluation_quiet(processed_data_dim5, emi_func, raw_func, use_saved_coords)
    
    preavg_cd = squeeze(processed_data_dim5(:, :, 1, 1, :, :));
    preavg_cd2 = squeeze(processed_data_dim5(:, :, 1, 2, :, :));
    primary = squeeze(processed_data_dim5(:, :, 1, 1, :, 1));
    primary2 = squeeze(processed_data_dim5(:, :, 1, 2, :, 1));

    img1 = emi_func(preavg_cd);
    img2 = emi_func(preavg_cd2);

    raw1 = raw_func(primary);
    raw2 = raw_func(primary2);
    
    if nargin < 4
        use_saved_coords = true; %default
    end
end 