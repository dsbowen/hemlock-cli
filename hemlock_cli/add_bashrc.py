"""Modify .bashrc

example:
$ python3 add_bashrc new_line
"""

import os
import sys

profile_path = os.path.join(os.environ.get('HOME'), '.bashrc')
profile = open(profile_path, 'a')
profile.write('\n'+sys.argv[1])
profile.close()