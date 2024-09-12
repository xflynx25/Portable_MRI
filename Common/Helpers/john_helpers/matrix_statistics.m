function stats = matrix_statistics(matrix)
    % MATRIX_STATISTICS computes basic statistics (max, min, mean, std) on a 2D matrix.
    % Input:
    %   matrix - a 2D matrix
    % Output:
    %   stats - a struct containing min, max, mean, std of the matrix elements

    % Flatten the 2D matrix into a 1D array
    flattened_matrix = matrix(:);

    % Compute statistics
    stats.min = min(flattened_matrix);       % Minimum value
    stats.max = max(flattened_matrix);       % Maximum value
    stats.mean = mean(flattened_matrix);     % Mean (average)
    stats.median = median(flattened_matrix); % Median value
    stats.std = std(flattened_matrix);       % Standard deviation
    stats.var = var(flattened_matrix);       % Variance
    stats.range = stats.max - stats.min;     % Manual computation of range
end
