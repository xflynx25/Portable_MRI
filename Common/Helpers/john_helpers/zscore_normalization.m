function normalized_data = zscore_normalization(data)
%MY_ZSCORE Performs z-score normalization on input data.
%
%   normalized_data = MY_ZSCORE(data) returns the z-score normalized version
%   of the input matrix 'data'. Each column of 'data' is normalized to have
%   a mean of 0 and a standard deviation of 1.
%
%   Inputs:
%       data - A numeric matrix where each column represents a different signal.
%
%   Outputs:
%       normalized_data - The z-score normalized matrix.

    % Check if input is numeric
    if ~isnumeric(data)
        error('Input data must be a numeric matrix.');
    end

    % Calculate the mean of each column
    means = mean(data, 1);

    % Calculate the standard deviation of each column
    % The second argument '0' specifies normalization by N-1 (sample standard deviation)
    stds = std(data, 0, 1);

    % Handle columns with zero standard deviation to avoid division by zero
    zero_std_indices = stds == 0;
    if any(zero_std_indices)
        warning('One or more columns have zero standard deviation. These columns will be set to zero.');
        stds(zero_std_indices) = 1;  % Temporarily set std to 1 to avoid division by zero
    end

    % Perform z-score normalization
    normalized_data = (data - means) ./ stds;

    % Set columns with original zero standard deviation to zero
    normalized_data(:, zero_std_indices) = 0;
end
