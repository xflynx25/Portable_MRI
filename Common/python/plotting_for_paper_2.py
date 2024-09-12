import matplotlib.pyplot as plt
import seaborn as sns
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

# we want to make a plot that steps through these 4 different detector types, and plots some box whisker on this, color coded for each letter detector?
# Prepare data for plotting
rows = []
for scan, detectors in data.items():
    for detector, values in detectors.items():
        for stat in values:
            rows.append([scan, detector, stat])

# Convert to pandas DataFrame
df = pd.DataFrame(rows, columns=['Scan', 'Detector', 'Value'])

# Create the boxplot
plt.figure(figsize=(10, 6))
sns.boxplot(x='Scan', y='Value', hue='Detector', data=df, palette='Set1')

# Customize the plot
plt.title('Box-and-Whisker Plot for Detector Stats Across Scans')
plt.xlabel('Scan Type')
plt.ylabel('Value')
plt.legend(title='Detector')
plt.show()