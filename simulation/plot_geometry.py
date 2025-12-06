import re
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import mpl_toolkits.mplot3d.art3d as art3d
import numpy as np

def parse_fds_obst(file_path):
    obstructions = []
    with open(file_path, 'r') as f:
        for line_num, line in enumerate(f, 1):
            if '&OBST' in line:
                # Extract XB coordinates
                # Look for XB= followed by numbers/commas
                match = re.search(r'XB\s*=\s*([\d\.\-,\s]+)', line)
                if match:
                    coords_str = match.group(1).replace(' ', '').split(',')
                    try:
                        coords = [float(x) for x in coords_str if x.strip()]
                        if len(coords) != 6:
                            print(f"Warning: Line {line_num}: Found {len(coords)} coordinates, expected 6. Skipping: {line.strip()}")
                            continue
                            
                        # Extract Surface ID for coloring
                        surf_match = re.search(r"SURF_ID\s*=\s*'([^']+)'", line)
                        surf_id = surf_match.group(1) if surf_match else 'UNKNOWN'
                        
                        obstructions.append({'coords': coords, 'surf_id': surf_id})
                    except ValueError as e:
                         print(f"Error parsing line {line_num}: {e}. Line: {line.strip()}")
    return obstructions

def plot_geometry(obstructions):
    fig = plt.figure(figsize=(12, 10))
    ax = fig.add_subplot(111, projection='3d')
    
    colors = {
        'WALL_SURF': 'gray',
        'STYROFOAM_COVER': 'white',
        'BAMBOO_SURF': 'peru', # Tan/Brown
        'PP_NET_SURF': 'blue',
        'CATCH_FAN_SURF': 'brown',
        'UNKNOWN': 'red'
    }
    
    alphas = {
        'WALL_SURF': 0.3,
        'STYROFOAM_COVER': 0.9,
        'BAMBOO_SURF': 0.8,
        'PP_NET_SURF': 0.2, # See-through
        'CATCH_FAN_SURF': 1.0
    }

    print(f"Plotting {len(obstructions)} obstructions...")

    for obj in obstructions:
        x1, x2, y1, y2, z1, z2 = obj['coords']
        dx = x2 - x1
        dy = y2 - y1
        dz = z2 - z1
        
        # Skip very thin objects for better performance if needed, or plot as surfaces
        # For now, plot everything as bars
        
        color = colors.get(obj['surf_id'], 'red')
        alpha = alphas.get(obj['surf_id'], 0.5)
        
        # Create a 3D box
        ax.bar3d(x1, y1, z1, dx, dy, dz, color=color, alpha=alpha, edgecolor='k', linewidth=0.1)

    ax.set_xlabel('X (Width)')
    ax.set_ylabel('Y (Depth)')
    ax.set_zlabel('Z (Height)')
    ax.set_title('Wang Fuk Court Scaffolding Model (Tier 1 Strip)')
    
    # Set view to see the gap (side view)
    ax.view_init(elev=20, azim=-45)
    
    # Set approximate limits
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6)
    ax.set_zlim(0, 30)
    
    plt.savefig('geometry_viz.png')
    print("Plot saved to geometry_viz.png")

if __name__ == "__main__":
    fds_file = 'tier1_1_bamboo_PP_styro_strip.fds'
    print(f"Parsing {fds_file}...")
    obsts = parse_fds_obst(fds_file)
    plot_geometry(obsts)
