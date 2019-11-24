"""Update yaml file with assignment

`assignment` is variable=value.
"""

import sys
import yaml

yaml_path, assignment = sys.argv[1:3]
var, val = assignment.split('=')
with open(yaml_path, 'r') as yaml_file:
    content = yaml.safe_load(yaml_file) or {}
content.update({var: val})
with open(yaml_path, 'w') as yaml_file:
    yaml.dump(content, yaml_file)