"""Export environment variables from yaml file

Prints var=val for each entry in yaml file. In the command line, use 
$export `python3 export_yaml.py my_file.yaml` to export environment 
variables.
"""

import sys
import yaml

yaml_path = sys.argv[1]
with open(yaml_path, 'r') as yaml_file:
    env = yaml.safe_load(yaml_file) or {}
print(' '.join(['{0}={1}'.format(var, val) for var, val, in env.items()]))