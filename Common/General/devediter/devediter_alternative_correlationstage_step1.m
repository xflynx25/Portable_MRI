function [win_stack] = devediter_alternative_correlationstage_step1(combined_data, starter_kern_stack, correlation_eps, mingroupsize)
    % Function to create groups based on pairwise correlations with a minimum group size constraint
    %
    % Parameters:
    % combined_data        - The combined dataset (unused in current logic)
    % starter_kern_stack   - Cell array of kernel stacks
    % correlation_eps      - Correlation threshold
    % mingroupsize         - Minimum number of elements in each group
    %
    % Returns:
    % win_stack            - Cell array containing the grouped indices

    % variables we need to recompute
    ncol = size(combined_data, 1);
    nlin = size(combined_data, 2);

    % Normalize kernels and compute correlation matrix
    num_groups = size(starter_kern_stack, 1); 
    size_kernel = size(starter_kern_stack{1}, 1);
    kern_pe_normalized = zeros(size_kernel, num_groups);
    for clin = 1:nlin
        norm_val = norm(starter_kern_stack{clin});
        if norm_val == 0
            warning(['Kernel at index ', num2str(clin), ' has zero norm and will be skipped.']);
            kern_pe_normalized(:, clin) = zeros(size_kernel, 1);
        else
            kern_pe_normalized(:, clin) = starter_kern_stack{clin} / norm_val;
        end
    end
    kcor = kern_pe_normalized' * kern_pe_normalized;
    %kcor

    % Threshold calculation
    kcor_thresh = abs(kcor) > correlation_eps;
    %kcor_thresh

    % Determine window stack (temporal clusters)
    aval_lins = 1:nlin;
    win_stack = cell(nlin, 1);
    cwin = 1;

    while ~isempty(aval_lins)
        clin = min(aval_lins);
        disp(['Processing line: ', num2str(clin)]);
        
        % Extract the correlation row for clin
        corr_row = kcor_thresh(clin, clin:end);
        
        % Find the first zero in the correlation row after clin
        first_zero_idx = find(corr_row == 0, 1, 'first');
        
        if isempty(first_zero_idx)
            % No zero found; include all remaining PE lines
            pe_rng = clin : nlin;
        elseif first_zero_idx == 1
            % The current clin has no high correlation with itself (unlikely)
            pe_rng = clin;
        else
            % Include PE lines up to the first zero
            pe_rng = clin : clin + first_zero_idx - 2;
        end
        
        % Ensure pe_rng is within the available lines
        pe_rng = pe_rng(pe_rng >= 1 & pe_rng <= nlin);

        %% ADJUST IF DOESN'T SATISFY THE MINGROUPSIZE CONSTRAINT, OR WILL
        % VIOLATE ON NEXT ROUND

        group_size = length(pe_rng);
        remaining_after_group = nlin - pe_rng(end);

        % **First Check**: If current group is smaller than mingroupsize
        if group_size < mingroupsize
            % Calculate the number of lines needed to meet mingroupsize
            additional_needed = mingroupsize - group_size;
            % Determine the new end index for the group
            new_end = min(pe_rng(end) + additional_needed, nlin);
            % Update pe_rng to include the necessary additional lines
            pe_rng = clin : new_end;
            group_size = length(pe_rng);
            remaining_after_group = nlin - pe_rng(end);
        end

        % **Second Check**: If remaining lines after this group are fewer than mingroupsize
        if remaining_after_group > 0 && remaining_after_group < mingroupsize
            % Include the remaining lines into the current group
            pe_rng = clin : nlin;
        end



        % Assign to win_stack
        win_stack{cwin} = pe_rng;
        cwin = cwin + 1;
        
        % Remove the assigned lines from aval_lins
        aval_lins = setdiff(aval_lins, pe_rng);
    end
    win_stack = win_stack(1:cwin - 1);
    %disp(win_stack)
    disp('win stack displayed')

    % --- Visualization of Correlation Matrix with Group Boundaries ---
    visualize_correlation_matrix(abs(kcor), win_stack, correlation_eps);
    % --- End of Visualization ---
end
