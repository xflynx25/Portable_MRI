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
    
    % Threshold calculation
    kcor_thresh = abs(kcor) > correlation_eps;

    % Determine window stack (temporal clusters)
    aval_lins = 1:nlin;
    win_stack = cell(nlin, 1);
    cwin = 1;
    
    while ~isempty(aval_lins)
        clin = min(aval_lins);
        pe_rng = clin:clin + max(find(kcor_thresh(clin, clin:end))) - 1;
        win_stack{cwin} = pe_rng;
        aval_lins = sort(setdiff(aval_lins, pe_rng), 'ascend');
        cwin = cwin + 1;
    end
    
    % Drop the empty last entry 
    win_stack = win_stack(1:cwin - 1);
    disp(win_stack)
end 