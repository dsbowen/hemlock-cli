"""Modify .bashrc

example:
$ python3 add_bashrc new_line
"""

import os
import sys

profile_path = os.path.join(os.environ.get('HOME'), '.bashrc')
with open(profile_path, 'r') as profile_f:
    profile = profile_f.read()
profile = profile.splitlines()
profile = [line for line in profile if line != sys.argv[1]] + [sys.argv[1]]
with open(profile_path, 'w') as profile_f:
    profile_f.write('\n'.join(profile))