import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Sample data from the user's description
data = {
    'Condition': ['no power', 'Empty', 'C1 (far front large)', 'C2 (far middle med)', 'C3 (far back large)', 
                  'C4 (middle back small)', 'C5 (front middle large)', 'C6 (under middle large)'],
    'd1_day1': [7.5, 7.5, 35, 11000, 69, np.nan, np.nan, np.nan],
    'd1_day2': [1.4, 1.68, np.nan, 11.2, np.nan, np.nan, np.nan, 11000],
    'd2_day1': [7.2, 8.0, 221, 247, 290, 389, 227, 63],
    'd2_day2': [0.86, 3.7, 325, 336, 392, 210, 220, 44],
    'd3_day1': [7.4, 16.9, 290, 626, 639, 566, 315, 83],
    'd3_day2': [0.84, 14.4, np.nan, np.nan, 266, 169, 190, 26],
    'd4_day1': [2.5, 1.5, 49, 95, 90, 73, 160, 23.2],
    'd4_day2': [1.10, 1.49, np.nan, 99, np.nan, 149, 81, 41]
}

# Create DataFrame
df = pd.DataFrame(data)

# Setting the x-axis for the conditions
x = df['Condition']

# Create a figure and axis objects for the plot
fig, ax = plt.subplots()


# Updating the plot based on user feedback
fig, ax = plt.subplots()

# Define consistent colors for each day and use different markers
colors = ['blue', 'orange', 'green', 'red']  # same color for both trials of each day
markers = ['s', 'o']  # square and circle with hole

for i, trial in enumerate(['d1', 'd2', 'd3', 'd4']):
    # Plot first trial with a square marker
    ax.plot(x, df[f'{trial}_day1'], label=f'{trial}, day 1', marker=markers[0], color=colors[i], linestyle=':')
    # Plot second trial with a circle marker (with a hole)
    ax.plot(x, df[f'{trial}_day2'], label=f'{trial}, day 2', marker=markers[1], color=colors[i], linestyle=':')

# Log scale for the y-axis
ax.set_yscale('log')

# Adding labels and title
ax.set_xlabel('Pickup Coil Connection')
ax.set_ylabel('Measured VPP (mV)')
ax.set_title('Noise Measurement for Coil-Preamp Combinations (Log Scale)')

# Rotate x-axis labels for better readability
plt.xticks(rotation=45, ha='right')

ax.grid()

# Adding a legend
ax.legend()

# Display the plot
plt.tight_layout()
plt.show()
