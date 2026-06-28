#!/usr/bin/env python3
"""Regenerate the inline CONFIGS array in benchmark.html from data/configs.json.

The benchmark dashboard renders from an inline `const CONFIGS = [...]` array so it
keeps working when opened directly (file://). This script makes that array
data-driven: data/configs.json is the single source of truth, and running this
script rewrites only the array between the CONFIGS_DATA markers. It does not touch
the dashboard's layout, styling, chart configuration, or copy.
"""

import json
import os
import re
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIGS_JSON = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "webapp", "data", "configs.json"))
HTML_FILE = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "webapp", "benchmark.html"))

START = "/* CONFIGS_DATA_START */"
END = "/* CONFIGS_DATA_END */"


def build_block(configs):
    lines = json.dumps(configs, indent=2).splitlines()
    # Indent every line after the first so the array nests under `const CONFIGS =`.
    joined = "\n".join([lines[0]] + ["      " + line for line in lines[1:]])
    return f"{START}\n      const CONFIGS = {joined};\n      {END}"


def main():
    with open(CONFIGS_JSON) as f:
        configs = json.load(f)["configs"]

    with open(HTML_FILE) as f:
        html = f.read()

    pattern = re.compile(re.escape(START) + r".*?" + re.escape(END), re.DOTALL)
    if not pattern.search(html):
        print(f"Error: CONFIGS markers not found in {HTML_FILE}", file=sys.stderr)
        sys.exit(1)

    new_html = pattern.sub(lambda _: build_block(configs), html)
    with open(HTML_FILE, "w") as f:
        f.write(new_html)

    print(f"Updated CONFIGS in {HTML_FILE} ({len(configs)} configurations from {CONFIGS_JSON})")


if __name__ == "__main__":
    main()
