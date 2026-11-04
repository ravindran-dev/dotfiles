#!/usr/bin/env python3
"""Choose a Fastfetch layout for the current terminal; clip compact output safely."""
import re
import subprocess
import sys
import unicodedata

width = max(4, int(sys.argv[1]))
height = max(4, int(sys.argv[2]))
if width >= 110 and height >= 32:
    subprocess.run(['fastfetch', '--logo-width', str(min(30, width // 4)),
                    '--logo-height', str(min(22, height - 8))])
else:
    modules = ('os:kernel:wm:cpu:memory:uptime' if width >= 55 and height >= 20
               else 'os:memory:uptime' if height >= 12 else 'os')
    p = subprocess.run(['fastfetch', '--config', 'none', '--logo', 'none',
                        '--structure', modules, '--pipe', 'true'],
                       capture_output=True, text=True)
    for line in p.stdout.splitlines()[:max(1, height - 5)]:
        line = re.sub(r'\x1b\[[0-?]*[ -/]*[@-~]', '', line)
        result, used = '', 0
        for char in line:
            cells = 0 if unicodedata.combining(char) else 2 if unicodedata.east_asian_width(char) in 'WF' else 1
            if used + cells > width - 3:
                result += '…'
                break
            result += char
            used += cells
        print('\033[36m' + result + '\033[0m')
