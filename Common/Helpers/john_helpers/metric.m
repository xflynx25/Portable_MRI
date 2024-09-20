function metric_value = metric(data, scoretype)
    cd = squeeze(data(:, :, 1, 1, 1, :));
    primary = shiftyifft(cd(:, :, 1));
    switch scoretype
        case 'power'
            % Example: average of all values
            metric_value = mean(real(primary(:)));
        case 'SNR_base'
            metric_value = calculate_snr_saving2d(primary, true);
        case 'SNR_editer'
            [~, ~, metric_value] = devediter_full_autotuned_simplified(cd, 1, 1, 0, 1, 1, 3, 10);
        case 'max'
            % Example: maximum value in data
            metric_value = max(data(:));
        
        case 'min'
            % Example: minimum value in data
            metric_value = min(data(:));
        
        otherwise
            % Error for unrecognized scoretype
            error('Unrecognized scoretype: %s', scoretype);
    end
end