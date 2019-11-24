import json
import os
import sys

origin = sys.argv[1]
cors_dir = os.path.dirname(os.path.abspath(__file__))
cors_path = os.path.join(cors_dir, 'cors.json')
with open(cors_path, 'r') as cors_file:
    cors = json.load(cors_file)
cors_rule = cors[0]
cors_rule['origin'] = [origin]
with open('cors.json', 'w') as new_cors_file:
    json.dump(cors, new_cors_file)