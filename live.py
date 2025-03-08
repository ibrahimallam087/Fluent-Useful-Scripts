import os
import time
import numpy as np
import matplotlib.pyplot as plt

# Disable LaTeX rendering to avoid errors
plt.rcParams.update({"text.usetex": False, "font.family": "serif"})

# Set the correct absolute path
directory = r"E:\Projects\Cav_Design_haack_Geom\Cav_hack_series_files\dp0\FFF-10\Fluent"
file_path = os.path.join(directory, "drag-rfile.out")

# Check if the directory exists
if not os.path.exists(directory):
    print(f"Error: The directory does not exist -> {directory}")
    exit()

print(f"Checking for file: {file_path}")

# Wait until the file appears
while not os.path.exists(file_path):
    print(f"Waiting for {file_path} to be created...")
    time.sleep(2)  # Wait 2 seconds before checking again

print("File detected! Now starting live plotting...")

# Initialize plot
plt.ion()
fig, ax = plt.subplots()
fig.set_facecolor("#f5f5f5")  # Light background like Excel
time_steps = []
drag_values = []
steady_drag = 0.0026  # Constant reference line

while True:
    try:
        # Read the file and extract data
        with open(file_path, "r") as file:
            lines = file.readlines()

        if len(lines) < 3:
            continue  # Skip if the file is too short

        # Filter out header and extract numerical data
        data = []
        for line in lines:
            parts = line.strip().split()
            if (
                len(parts) >= 2 and parts[0].isdigit()
            ):  # Ensure first column is a number
                try:
                    data.append([int(parts[0]), float(parts[1])])  # Time Step, Drag
                except ValueError:
                    continue  # Skip any problematic lines

        if not data:
            continue  # Skip if no valid data is found

        time_steps, drag_values = zip(*data)  # Unzip data into separate lists

        # Clear and replot the figure
        ax.clear()
        ax.set_facecolor("#ffffff")  # White background
        ax.plot(time_steps, drag_values, label="Drag", color="#007acc", linewidth=2)
        ax.axhline(
            steady_drag,
            color="#ff6600",
            linestyle="--",
            linewidth=2,
            label="Steady Drag (0.0026)",
        )
        ax.set_xlabel("Time Step", fontsize=12)
        ax.set_ylabel("Drag", fontsize=12)
        ax.set_title("Live Drag Plot", fontsize=14)
        ax.legend(fontsize=10)
        ax.grid(True, linestyle="--", alpha=0.6)
        ax.set_ylim(0, 0.02)  # Set y-axis limits from 0 to 0.02

        plt.draw()
        plt.pause(2)  # Update every 2 seconds

    except Exception as e:
        print(f"Error reading file: {e}")
        time.sleep(2)  # Wait before retrying
