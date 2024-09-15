function visualize_correlation_matrix(kcor, win_stack, correlation_eps)
    % visualize_correlation_matrix - Visualizes the correlation matrix with group boundaries
    %
    % Syntax: visualize_correlation_matrix(kcor, win_stack, correlation_eps)
    %
    % Inputs:
    %   kcor            - Correlation matrix (nlin x nlin)
    %   win_stack       - Cell array containing PE line groupings
    %   correlation_eps - Correlation threshold used for grouping
    %
    % Outputs:
    %   Figure displaying the heatmap with group boundaries

    % Number of groups based on win_stack
    num_groups = length(win_stack);

    % Calculate the size of each group
    group_sizes = cellfun(@length, win_stack);

    % Calculate cumulative group sizes to determine boundary positions
    cumulative_group_sizes = cumsum(group_sizes);

    % Total number of PE lines
    nlin = size(kcor, 1);

    % Create a new figure with a larger size for better visibility
    figure('Name', 'Correlation Matrix Heatmap with Group Boundaries', 'NumberTitle', 'off', 'Position', [100, 100, 800, 800]);
    hold on;

    % Plot the heatmap using imagesc
    imagesc(kcor);
    colormap('jet'); % Choose a colormap
    colorbar;
    axis square;
    title(sprintf('Correlation Matrix Heatmap (Threshold: %.2f)', correlation_eps), 'FontSize', 14);
    xlabel('Group Index', 'FontSize', 12);
    ylabel('Group Index', 'FontSize', 12);

    % Adjust the axes to ensure correct alignment
    set(gca, 'XTick', 1:nlin, 'YTick', 1:nlin);
    axis([0.5 nlin + 0.5 0.5 nlin + 0.5]);

    % Overlay lines to indicate group boundaries
    for g = 1:num_groups-1
        % Position lines between groups based on cumulative group sizes
        boundary = cumulative_group_sizes(g) + 0.5;

        % Draw vertical boundary line
        plot([boundary boundary], [0.5 nlin + 0.5], 'w-', 'LineWidth', 2);

        % Draw horizontal boundary line
        plot([0.5 nlin + 0.5], [boundary boundary], 'w-', 'LineWidth', 2);
    end

    % Annotate group numbers at the center of each group block
    for g = 1:num_groups
        % Calculate the center position of the group block
        if g == 1
            start_pos = 1;
        else
            start_pos = cumulative_group_sizes(g-1) + 1;
        end
        end_pos = cumulative_group_sizes(g);
        center = (start_pos + end_pos) / 2;

        % Place the group number at the center
        text(center, center, sprintf('%d', g), 'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'middle', 'Color', 'k', 'FontWeight', 'bold', 'FontSize', 12);
    end

    hold off;

    % Save the figure
    saveas(gcf, 'Correlation_Matrix_Heatmap.png');

    disp('Correlation matrix heatmap has been generated and saved as "Correlation_Matrix_Heatmap.png".');
end
