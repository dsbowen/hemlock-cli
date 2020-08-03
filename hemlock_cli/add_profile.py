"""Add a line to bash profile

example:
$ python3 add_profile new_line
"""

import os
import sys

path = ''
profile_filenames = ['.profile', '.bash_login', '.bash_profile', '.bashrc']
for f in profile_filenames:
    path = os.path.join(os.environ.get('HOME'), f)
    if os.path.exists(path):
        break
with open(path, 'r') as profile_f:
    profile = profile_f.read()
profile = profile.splitlines()
profile = [line for line in profile if line != sys.argv[1]] + [sys.argv[1]]
with open(path, 'w') as profile_f:
    profile_f.write('\n'.join(profile))