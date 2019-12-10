"""Update yaml file"""

import os
import sys
import yaml

def export(content, assignments):
    """Export variables"""
    for a in assignments:
        var, val = a.split('=')
        content.update({var:val})

def unset(content, vars):
    """Remove variables"""
    for v in vars:
        try:
            content.pop(v)
        except:
            pass

def clean_args(args):
    """Clean arguments from str(tuple) to list"""
    for c in ['(',"'",')', ' ']:
        args = args.replace(c,'')
    args = args.split(',')
    try:
        args.remove('')
    except:
        pass
    return args

if __name__ == '__main__':
    yaml_path, operation = sys.argv[1:]
    with open(yaml_path, 'r') as yaml_file:
        content = yaml.safe_load(yaml_file) or {}
    if operation == 'export':
        export(content, clean_args(os.environ['assignments']))
    if operation == 'unset':
        unset(content, clean_args(os.environ['vars']))
    with open(yaml_path, 'w') as yaml_file:
        yaml.dump(content, yaml_file)