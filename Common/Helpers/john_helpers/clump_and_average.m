function reduced_array = clump_and_average(array, index_groups, dim)
    % CLUMP_AND_AVERAGE averages groups of indices along a specified dimension
    % and reduces the size of that dimension accordingly.
    %
    % Inputs:
    % - array: The input multidimensional array
    % - index_groups: A cell array of index groups to average (e.g., {[1,3,5], [2,4,6]})
    % - dim: The dimension along which to apply the clumping and averaging
    %
    % Output:
    % - reduced_array: The resulting array with averaged values and a reduced dimension size

    % Initialize the result by taking the average of the first group
    subs = repmat({':'}, 1, ndims(array));  % Create cell array for indexing
    subs{dim} = index_groups{1};  % Set the first index group
    slice_group = array(subs{:});  % Extract the slices for the first group
    averaged_slice = mean(slice_group, dim);  % Average along the specified dimension
    
    % Initialize reduced array with the first averaged slice
    reduced_array = averaged_slice;

    % Loop through the remaining index groups and concatenate the averaged results
    for i = 2:length(index_groups)
        subs{dim} = index_groups{i};  % Update the index for the current group
        slice_group = array(subs{:});  % Extract the slices for the current group
        averaged_slice = mean(slice_group, dim);  % Average along the specified dimension
        
        % Concatenate along the specified dimension
        reduced_array = cat(dim, reduced_array, averaged_slice);
    end
end
