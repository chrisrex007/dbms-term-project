#!/usr/bin/env python3
"""
compare_configs.py — Multi-Configuration Benchmark Comparison
Generates comparison charts from the benchmark data across all 4 Solr configurations.
"""

import os
import json
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np
from datetime import datetime

# benchmark data from notes.txt
CONFIGS = {
    "Standalone (1 core)": {
        "color": "#22c55e",
        "data": [
            (1.95, 6970, 9.09, 766.78),
            (2.93, 17162, 9.93, 1728.30),
            (4.86, 18041, 9.93, 1816.82),
            (6.74, 36905, 9.93, 3716.52),
            (10.64, 46845, 9.95, 4708.04),
            (12.63, 41654, 9.95, 4186.33),
            (16.61, 39735, 9.94, 3997.48),
            (18.64, 36789, 9.94, 3701.11),
            (22.62, 37421, 9.94, 3764.69),
            (28.62, 37750, 9.94, 3797.79),
            (30.58, 37371, 9.94, 3759.66),
            (36.62, 37597, 9.94, 3782.39),
            (40.58, 38513, 9.94, 3874.55),
            (42.6, 37896, 9.94, 3812.47),
            (46.6, 37993, 9.94, 3822.23),
            (52.55, 37336, 9.95, 3752.36),
            (58.46, 34965, 9.93, 3521.15),
            (60.51, 32272, 9.95, 3243.42),
            (66.46, 32297, 9.92, 3255.75),
            (70.38, 32365, 9.94, 3256.04),
            (72.46, 32262, 9.94, 3245.67),
            (77.94, 32410, 9.93, 3263.85),
        ]
    },
    "1-Node Cloud\n(2s×2r, 1 ZK)": {
        "color": "#818cf8",
        "data": [
            (1.94, 4989, 9.71, 513.80),
            (2.9, 13308, 9.96, 1336.14),
            (0.76, 2586, 9.96, 259.64),
        ]
    },
    "3-Node Cloud\n(3s×4r, 1 ZK)": {
        "color": "#f59e0b",
        "data": [
            (1.97, 3371, 9.43, 357.48),
            (2.92, 6458, 9.95, 649.05),
            (4.83, 20543, 9.95, 2064.62),
            (6.75, 29345, 9.96, 2946.29),
            (5.58, 23721, 9.96, 2381.63),
            (0.58, 1468, 9.96, 147.39),
            (2.32, 7265, 9.96, 729.42),
            (3.66, 12346, 9.94, 1242.05),
            (0.97, 1424, 9.96, 142.97),
            (2.54, 8266, 9.94, 831.59),
            (1.7, 3515, 9.94, 353.62),
            (1.4, 3369, 9.94, 338.93),
        ]
    },
    "3-Node Cloud\n(3s×4r, 3 ZK)": {
        "color": "#f87171",
        "data": [
            (1.96, 3230, 9.61, 336.11),
            (2.94, 7597, 9.95, 763.52),
            (1.08, 3709, 9.96, 372.39),
            (2.45, 7955, 9.94, 800.30),
            (1.05, 3183, 9.96, 319.58),
            (1.3, 3930, 9.94, 395.37),
            (2.03, 6682, 9.94, 672.23),
            (1.76, 4772, 9.94, 480.08),
        ]
    }
}

def create_all_charts(output_dir):
    os.makedirs(output_dir, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    # Use dark background
    plt.style.use('dark_background')
    plt.rcParams.update({
        'font.family': 'sans-serif',
        'font.size': 11,
        'axes.facecolor': '#1a1a2e',
        'figure.facecolor': '#0f0f1a',
        'grid.color': (1.0, 1.0, 1.0, 0.06),
    })

    # 1. Combined QPS vs Concurrency
    fig, ax = plt.subplots(figsize=(12, 7))
    for name, config in CONFIGS.items():
        concurrency = [d[0] for d in config["data"]]
        qps = [d[3] for d in config["data"]]
        ax.plot(concurrency, qps, 'o-', color=config["color"],
                linewidth=2, markersize=5, label=name.replace('\n', ' '), alpha=0.9)
    ax.set_xlabel('Measured Concurrency', fontsize=13)
    ax.set_ylabel('Queries Per Second (QPS)', fontsize=13)
    ax.set_title('QPS vs Concurrency — All Configurations', fontsize=16, fontweight='bold', pad=15)
    ax.legend(loc='upper right', framealpha=0.8)
    ax.grid(True, alpha=0.15)
    plt.tight_layout()
    plt.savefig(f"{output_dir}/comparison_qps_{timestamp}.png", dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved: comparison_qps_{timestamp}.png")

    # 2. Peak QPS bar comparison
    fig, ax = plt.subplots(figsize=(10, 6))
    names = [n.replace('\n', ' ') for n in CONFIGS.keys()]
    colors = [c["color"] for c in CONFIGS.values()]
    peaks = [max(d[3] for d in c["data"]) for c in CONFIGS.values()]

    bars = ax.bar(range(len(names)), peaks, color=colors, alpha=0.8,
                  edgecolor=colors, linewidth=2, width=0.6)
    for bar, peak in zip(bars, peaks):
        ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 50,
                f'{peak:,.0f}', ha='center', va='bottom', fontweight='bold', fontsize=12, color='white')

    ax.set_xticks(range(len(names)))
    ax.set_xticklabels(names, fontsize=10)
    ax.set_ylabel('Peak QPS', fontsize=13)
    ax.set_title('Peak QPS by Configuration', fontsize=16, fontweight='bold', pad=15)
    ax.grid(True, axis='y', alpha=0.15)
    plt.tight_layout()
    plt.savefig(f"{output_dir}/comparison_peak_{timestamp}.png", dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved: comparison_peak_{timestamp}.png")

    # 3. Standalone detailed scaling curve
    sa = CONFIGS["Standalone (1 core)"]
    concurrency = [d[0] for d in sa["data"]]
    qps = [d[3] for d in sa["data"]]

    fig, ax = plt.subplots(figsize=(12, 6))
    ax.fill_between(concurrency, qps, alpha=0.15, color='#22c55e')
    ax.plot(concurrency, qps, 'o-', color='#22c55e', linewidth=2.5, markersize=5)

    # Annotate peak
    peak_idx = qps.index(max(qps))
    ax.annotate(f'Peak: {qps[peak_idx]:,.0f} QPS',
                xy=(concurrency[peak_idx], qps[peak_idx]),
                xytext=(concurrency[peak_idx]+10, qps[peak_idx]+200),
                fontsize=11, fontweight='bold', color='#22c55e',
                arrowprops=dict(arrowstyle='->', color='#22c55e', lw=1.5))

    ax.set_xlabel('Measured Concurrency', fontsize=13)
    ax.set_ylabel('Queries Per Second', fontsize=13)
    ax.set_title('Standalone Solr — QPS Scaling Curve', fontsize=16, fontweight='bold', pad=15)
    ax.grid(True, alpha=0.15)
    plt.tight_layout()
    plt.savefig(f"{output_dir}/standalone_scaling_{timestamp}.png", dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved: standalone_scaling_{timestamp}.png")

    # 4. Summary markdown
    with open(f"{output_dir}/comparison_summary_{timestamp}.md", 'w') as f:
        f.write(f"# Multi-Configuration Benchmark Comparison\n\n")
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        f.write("## Peak Performance\n\n")
        f.write("| Configuration | Peak QPS | At Concurrency | Total Data Points |\n")
        f.write("|---------------|----------|----------------|-------------------|\n")
        for name, config in CONFIGS.items():
            peak = max(config["data"], key=lambda d: d[3])
            f.write(f"| {name.replace(chr(10), ' ')} | {peak[3]:,.2f} | {peak[0]:.2f} | {len(config['data'])} |\n")
        f.write("\n## Key Findings\n\n")
        f.write("- Standalone mode achieves the highest QPS (~4,708) on a single host\n")
        f.write("- SolrCloud overhead is significant when all nodes share hardware\n")
        f.write("- Adding ZooKeeper nodes on the same host reduces performance\n")
        f.write("- True distributed advantages require separate physical machines\n")

    print(f"  Saved: comparison_summary_{timestamp}.md")

    # Copy latest to webapp/images
    webapp_img_dir = os.path.join(os.path.dirname(output_dir), '..', 'webapp', 'images')
    os.makedirs(webapp_img_dir, exist_ok=True)

    import shutil
    for fname in [f"comparison_qps_{timestamp}.png", f"comparison_peak_{timestamp}.png", f"standalone_scaling_{timestamp}.png"]:
        src = os.path.join(output_dir, fname)
        # Also save as the "latest" version
        base = fname.rsplit('_', 1)[0]  # Remove timestamp
        dst = os.path.join(webapp_img_dir, f"{base}_latest.png")
        shutil.copy2(src, dst)
        print(f"  Copied → {dst}")

    print(f"\nAll comparison charts saved to {output_dir}")

if __name__ == "__main__":
    output_dir = os.path.join(os.path.dirname(__file__), 'visualizations')
    print("Generating multi-configuration comparison charts...")
    create_all_charts(output_dir)
    print("Done!")
