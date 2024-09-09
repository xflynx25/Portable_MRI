function sliced_array = slice_dimension(array, indices, dim)

    % Initialize the sliced_array by getting the first index
    subs = repmat({':'}, 1, ndims(array));  % Create a cell array for indexing
    subs{dim} = indices(1);  % Set the first index for the dimension
    sliced_array = array(subs{:});  % Extract the first slice
    
    % Loop through the remaining indices and concatenate
    for i = 2:length(indices)
        subs{dim} = indices(i);  % Update the index for the current slice
        slice = array(subs{:});  % Extract the current slice
        
        % Concatenate along the desired dimension
        sliced_array = cat(dim, sliced_array, slice);
    end
end
