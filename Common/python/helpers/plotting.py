import matplotlib.pyplot as plt
import numpy as np

def plot_with_scale(data, title_text, square_plot, scale_param, color_map='gray'):
    """
    Plots data with scaling options.

    Parameters:
    data (np.ndarray): 2D array to plot.
    title_text (str): Title for the plot.
    square_plot (bool): Whether to adjust the plot to a square aspect ratio.
    scale_param (float): Parameter for scaling. If between 0 and 1, it sets caxis cutoff. 
                         If greater than 1, it applies logarithmic scaling.
    color_map (str): Color map to use for plotting.
    """
    plotdata = data
    if scale_param != 0:
        if scale_param < 1:
            plt.clim(0, scale_param)
        else:
            logdata = data
            for logiter in range(int(scale_param)):
                logdata = np.log1p(logdata)
            plotdata = logdata

    plt.imshow(plotdata, cmap=color_map)
    
    if square_plot:
        x_size, y_size = data.shape
        plt.gca().set_aspect(y_size / x_size, adjustable='box')
    
    plt.title(title_text)

def plot_square_subplots(data, titles, suptitle, color_map='gray', scale_param=0, square_plot=True):
    """
    Plots data in a square grid of subplots.

    Parameters:
    data (list of np.ndarray): List of 2D arrays to plot.
    titles (list of str): Titles for each subplot.
    suptitle (str): Supertitle for the entire plot.
    color_map (str): Color map to use for plotting.
    scale_param (float): Parameter for scaling. Passed to plot_with_scale.
    square_plot (bool): Whether to adjust each plot to a square aspect ratio.
    """
    num_plots = len(data)
    grid_size = int(np.ceil(np.sqrt(num_plots)))
    rows = grid_size
    cols = grid_size if grid_size * (grid_size - 1) < num_plots else grid_size - 1
    
    fig, axes = plt.subplots(rows, cols, figsize=(cols * 5, rows * 5))
    fig.suptitle(suptitle)
    
    for i, (img, title) in enumerate(zip(data, titles)):
        row, col = divmod(i, cols)
        ax = axes[row, col] if rows > 1 and cols > 1 else axes[max(row, col)]
        plt.sca(ax)
        plot_with_scale(img, title, square_plot, scale_param, color_map)
        ax.axis('off')
    
    for j in range(i + 1, rows * cols):
        row, col = divmod(j, cols)
        fig.delaxes(axes[row, col] if rows > 1 and cols > 1 else axes[max(row, col)])
    
    plt.colorbar(ax=axes.ravel().tolist(), shrink=0.5)

# Example usage
if __name__ == "__main__":
    # Define example data
    data = [np.random.random((256, 40)) for _ in range(4)]
    titles = [f"Plot {i+1}" for i in range(4)]
    suptitle = "Example Plots with Log Scale"

    # Plot with log scale
    plot_square_subplots(data, titles, suptitle, scale_param=2, square_plot=True)
