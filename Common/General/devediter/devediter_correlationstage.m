function [win_stack] = devediter_correlationstage(combined_data, starter_kern_stack, correlation_eps)
    % Phase 2: find proper PE groupings
    % TODO: figure out what's going on with the max find commmand and
    % correct
    % TODO: visualize correlations 
    % TODO: offer alternative method here (for example N_G groups is a
    % chooseable parameter in the paper)


    % variables we need to recompute
    ncol = size(combined_data, 1);
    nlin = size(combined_data, 2);

    % Normalize kernels and compute correlation matrix
    num_groups = size(starter_kern_stack, 1); 
    size_kernel = size(starter_kern_stack{1}, 1);
    kern_pe_normalized = zeros(size_kernel, num_groups);
    for clin = 1:nlin
        kern_pe_normalized(:, clin) = starter_kern_stack{clin} / norm(starter_kern_stack{clin});
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
        disp(clin)
        
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