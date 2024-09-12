import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np 

# for each scan, list of each of the 3 detectors (p, c2, c4), and within each the stats of abs values of the magnitudes in ksp (max, mean, std)
# the mins are all 0 obviously 
data = {
    'ball1':{
        'p':  [755.7, 7.8915, 29.8575],
        'c2': [47.6760, 7.5631, 4.5427], 
        'c4': [35.7351, 6.5480, 3.9901]
    },
    'ball2':{
        'p':  [754.0723, 7.9032, 29.8184],
        'c2': [48.4665, 7.6273, 4.7177], 
        'c4': [37.6431, 6.5600, 4.0727]
    },
    'brainclean':{
        'p':  [275.2235, 3.9566, 9.1610],
        'c2': [34.0588, 7.0295, 3.9385], 
        'c4': [27.7308, 5.2481, 3.1507]
    },
    'brainnoisy':{
        'p':  [192.6266, 25.3798, 12.0073],
        'c2': [63, 22.4317, 10.3795], 
        'c4': [48.5077, 21.5430, 6.5623]
    },
}

# Prepare data for plotting
rows = []
for scan, detectors in data.items():
    for detector, values in detectors.items():
        for stat in values:
            rows.append([scan, detector, *values, 0])

# Convert to pandas DataFrame
df = pd.DataFrame(rows, columns=['Scan', 'Detector', 'max', 'mean', 'std', 'min'])

# Define a color palette for the detectors (you already have this from df)
palette = {'p': 'blue', 'c2': 'green', 'c4': 'orange'}

# Create two subplots (Broken axis layout) with more space for the bottom plot
fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True, figsize=(10, 8), gridspec_kw={'height_ratios': [1, 3]})

# Adjust the x-tick positions to avoid overlap by slightly shifting the detector data
x = np.arange(len(df['Scan'].unique()))  # Unique scans
width = 0.25  # Width for the offset

# Plot 1: Logarithmic scale for high values
for i, detector in enumerate(df['Detector'].unique()):
    detector_data = df[df['Detector'] == detector]
    means = detector_data.groupby('Scan')['mean'].mean()
    stds = detector_data.groupby('Scan')['std'].mean()
    max_vals = detector_data.groupby('Scan')['max'].mean()
    min_vals = detector_data.groupby('Scan')['min'].mean()
    
    # Offset the x values for each detector
    x_offset = x + i * width - width  # Shifts them to the side

    # Plot error bars with mean and std, set matching colors
    ax1.errorbar(x_offset, means, yerr=stds, fmt='o', color=palette[detector], capsize=5, label=f'{detector}')
    
    # Plot max and min with matching color
    ax1.scatter(x_offset, max_vals, marker='+', color=palette[detector])
    ax1.scatter(x_offset, min_vals, marker='+', color=palette[detector])

ax1.set_yscale('log')  # Logarithmic scale for the top plot
ax1.set_ylim(65, 800)  # Set limits for high values
ax1.spines['bottom'].set_visible(False)
ax1.tick_params(bottom=False)  # Hide bottom ticks on top plot

# Add dotted horizontal gridlines to the top plot
ax1.grid(True, which='both', axis='y', linestyle=':', color='grey', alpha=0.7)

# Plot 2: Linear scale for lower values
for i, detector in enumerate(df['Detector'].unique()):
    detector_data = df[df['Detector'] == detector]
    means = detector_data.groupby('Scan')['mean'].mean()
    stds = detector_data.groupby('Scan')['std'].mean()
    max_vals = detector_data.groupby('Scan')['max'].mean()
    min_vals = detector_data.groupby('Scan')['min'].mean()
    
    # Offset the x values for each detector
    x_offset = x + i * width - width  # Shifts them to the side

    # Plot error bars with mean and std, set matching colors
    ax2.errorbar(x_offset, means, yerr=stds, fmt='o', color=palette[detector], capsize=5)
    
    # Plot max and min with matching color
    ax2.scatter(x_offset, max_vals, marker='+', color=palette[detector])
    ax2.scatter(x_offset, min_vals, marker='+', color=palette[detector])

ax2.set_ylim(1, 65)  # Set limits for low values, but focus on the smaller range
ax2.spines['top'].set_visible(False)

# Add dotted horizontal gridlines to the bottom plot
ax2.grid(True, which='both', axis='y', linestyle=':', color='grey', alpha=0.7)

# Set x-ticks and label the scans in the middle of each group of detectors
scan_labels = df['Scan'].unique()
ax2.set_xticks(x)
ax2.set_xticklabels(scan_labels)


#ax1.get_yaxis().set_major_formatter(plt.ScalarFormatter())
#ax1.get_yaxis().set_minor_formatter(plt.ScalarFormatter())

# Diagonal break lines
d = .015  # Size of diagonal lines
kwargs = dict(transform=ax1.transAxes, color='k', clip_on=False)
ax1.plot((-d, +d), (-d, +d), **kwargs)  # Diagonal line on top-left
ax1.plot((1 - d, 1 + d), (-d, +d), **kwargs)  # Diagonal line on top-right

kwargs.update(transform=ax2.transAxes)  # Switch to the bottom axes
ax2.plot((-d, +d), (1 - d, 1 + d), **kwargs)  # Diagonal line on bottom-left
ax2.plot((1 - d, 1 + d), (1 - d, 1 + d), **kwargs)  # Diagonal line on bottom-right

# Single y-axis label for both plots
fig.text(0.04, 0.5, 'Signal Magnitudes', va='center', rotation='vertical')

# Final plot details
plt.subplots_adjust(hspace=0.05)  # Adjust space between plots
plt.suptitle('Voxel Magnitude Distributions by Detector across Scans')
plt.xlabel('Scan')
ax1.legend(title='Detector')  # Keep the legend on the top plot
plt.show()