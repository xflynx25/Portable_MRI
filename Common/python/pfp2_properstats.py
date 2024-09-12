import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np 
import pandas as pd

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
scans = list(data.keys())
detectors = ['p', 'c2', 'c4']

# Prepare list to hold boxplot data and positions
box_data = []
positions = []
detector_labels = []

# Iterate through each scan and detector
for i, scan in enumerate(scans):
    for j, detector in enumerate(detectors):
        max_val, mean_val, std_val = data[scan][detector]
        q1 = mean_val - std_val  # First quartile (mean - std)
        q3 = mean_val + std_val  # Third quartile (mean + std)
        
        # Boxplot data format: [min, Q1, median, Q3, max]
        box_data.append([0, q1, mean_val, q3, max_val])
        
        # Assign positions for each boxplot
        positions.append(i + j * 0.2)  # Offset each detector for the same scan slightly
        
        # Keep track of detector labels
        detector_labels.append(f'{scan} - {detector}')

# Plotting
fig, ax = plt.subplots(figsize=(10, 6))

# Create boxplot with positions and labels
ax.boxplot(box_data, positions=positions, widths=0.15)

# Customize the plot
ax.set_xticks(np.arange(len(scans)))
ax.set_xticklabels(scans)
ax.set_xlabel('Scan Type')
ax.set_ylabel('Value')
ax.set_title('Box-and-Whisker Plot for Detector Stats Across Scans')

# Add a legend manually (since Seaborn's legend won't apply to boxplot here)
plt.xticks(np.arange(len(scans)), scans)

plt.show()