"""Update requirements files"""

from pkg_resources import get_distribution
import sys

REQUIREMENTS_FILE_PATHS = ['requirements.txt', 'local-requirements.txt']

def update_requirements_files(pkg_name):
    """Update local and production requirements files with package"""
    [update_file(path, pkg_name) for path in REQUIREMENTS_FILE_PATHS]

def update_file(path, pkg_name):
    """Update a single requirements file with package"""
    with open(path, 'r') as requirements_f:
        lines = requirements_f.readlines()
    update_lines(lines, pkg_name)
    with open(path, 'w') as requirements_f:
        requirements_f.write(''.join(lines))

def update_lines(lines, pkg_name):
    """Update the lines of a requirements file"""
    version = get_distribution(pkg_name).version
    new_line = pkg_name+'=='+version+'\n'
    for i, line in enumerate(lines):
        line = line.split('==')[0].strip()
        if line == pkg_name:
            lines[i] = new_line
            return
        if line > pkg_name:
            lines.insert(i, new_line)
            return
    lines.append(new_line)

if __name__ == '__main__':
    pkg_names = sys.argv[1:]
    [update_requirements_files(pkg_name.strip()) for pkg_name in pkg_names]