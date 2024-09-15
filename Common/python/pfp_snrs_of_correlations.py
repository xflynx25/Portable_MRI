import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

cols = ['Clean (kx=0)', 'Clean (kx=2)', 'Noisy (kx=0)', 'Noisy (kx=2)']
rows = ['Individual Fits', 'First Bad Line Method', 'Correlation Box Method', 'One Fit For All']

data = [
    [27.98, 21.04, 3.68, 5.10],
    [28.63, 27.68, 3.62, 4.57],
    [29.48, 28.43, 3.56, 4.45],
    [29.47, 30.15, 3.55, 4.46]
]
# Create a DataFrame
df = pd.DataFrame(data, index=rows, columns=cols)

# Split into Clean and Noisy DataFrames
df_clean = df[['Clean (kx=0)', 'Clean (kx=2)']]
df_noisy = df[['Noisy (kx=0)', 'Noisy (kx=2)']]

# Set the overall style
sns.set(style="white")

# Create subplots with 1 row and 2 columns
fig, axes = plt.subplots(ncols=2, figsize=(14, 8), sharey=True)

# Adjust the layout to make room for titles and colorbars
fig.subplots_adjust(wspace=0.05)

# Plot the Clean Data heatmap
sns.heatmap(df_clean, annot=True, fmt=".2f", cmap='YlGnBu', ax=axes[0],
            cbar_kws={'label': 'Scale for Clean Data'})
axes[0].set_title('Clean Data')
axes[0].set_xlabel('')  # Remove x-label for cleaner look

# Plot the Noisy Data heatmap
sns.heatmap(df_noisy, annot=True, fmt=".2f", cmap='OrRd', ax=axes[1],
            cbar_kws={'label': 'Scale for Noisy Data'})
axes[1].set_title('Noisy Data')
axes[1].set_xlabel('')  # Remove x-label for cleaner look

# Set the y-axis labels only on the first subplot
axes[0].set_ylabel('Methods')
axes[0].tick_params(axis='y', labelsize=12)  # Adjust y-tick label size
axes[0].set_yticklabels(rows, rotation=0, fontsize=12)


# Set the x-tick labels rotation for better readability
for ax in axes:
    ax.set_xticklabels(ax.get_xticklabels(), rotation=45, ha='right')

axes[1].set_yticklabels([])

# Add an overall title
plt.suptitle('Heatmaps for Clean and Noisy Data Across Different Grouping Methods', fontsize=16, y=.98)

# Display the plot
plt.tight_layout()
plt.show()
