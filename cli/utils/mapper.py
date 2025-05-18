from __init__ import *
import os
import pandas as pd
import json

base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
schema_dir = os.path.join(base_dir, 'project', 'core', 'schema.xlsx')

def create_mapper():
    """
    Create a mapper.json file from the schema.xlsx file.
    The mapper.json file contains a mapping of node names to API calls.
    """
    schema = pd.read_excel(schema_dir, sheet_name="Sheet1")
    nodes, api_ref = schema[['node_name', 'api_call']].values.T
    jsonb = json.dumps(dict(zip(nodes, api_ref)), indent=4)
    with open(os.path.join(base_dir, 'cli', 'utils', 'mapper.json'), 'w') as f:
        f.write(jsonb)


if __name__ == '__main__':
    create_mapper()
    print("Mapper created successfully.")
