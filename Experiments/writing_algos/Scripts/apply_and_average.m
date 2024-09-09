function result = apply_and_average(func, data, dim)
    % APPLY_AND_AVERAGE applies a function along the specified dimension
    % and averages the results.
    %
    % Inputs:
    % - func: Function handle to be applied (e.g., @my_function)
    % - data: Input data to the function (multidimensional array)
    % - dim: Dimension over which to apply the function and average
    %
    % Output:
    % - result: Averaged result after applying the function along the dimension

    % Get the size of the input data along the specified dimension
    dim_size = size(data, dim);
   

    % Initialize an accumulator for the results
    result_sum = 0;

    % Apply the function across each slice along the specified dimension
    for i = 1:dim_size
        % Create dynamic indexing to extract the i-th slice along the dimension
        subs = repmat({':'}, 1, ndims(data));  % ':' for all dimensions
        subs{dim} = i;  % Replace the selected dimension with the current slice
        % Extract and squeeze the slice to remove singleton dimensions
        slice = squeeze(data(subs{:}));
        
        % Apply the function to the squeezed slice and accumulate the result
        result_sum = result_sum + func(slice);
    end

    % Average the accumulated results
    result = result_sum / dim_size;
end
