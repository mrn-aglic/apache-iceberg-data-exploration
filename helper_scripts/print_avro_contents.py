import ast
import json
import os
from pathlib import Path

import click
from avro.datafile import DataFileReader
from avro.io import DatumReader
from avro.schema import make_avsc_object


def byteToStr(input_dict):
    str_dict = str(input_dict)
    str_dict = str_dict.replace("b'", "'").replace("'", "\"")
    return ast.literal_eval(str_dict)


def delete_non_python_files():
    current_dir = os.path.dirname(os.path.realpath(__file__))

    print(current_dir)

    for filename in os.listdir(current_dir):
        if not filename.endswith("py"):
            os.remove(f"{current_dir}/{filename}")

def read_file(filepath, schema):
    p = Path(filepath)

    with open(filepath, 'rb') as f:
        avro_reader = DataFileReader(f, DatumReader(schema))
        rows = [row for row in avro_reader]

        str_rows = [byteToStr(row) for row in rows]

        name = p.name.split(".avro")[0]

        with open(f"helper_scripts/{name}.json", "w") as f:
            json.dump(str_rows, f, indent=4)


@click.command()
@click.option('--path', help="Provide file path")
@click.option('--all-dir', help="Provide directory path")
@click.option('--clear', is_flag=True)
def print_avro(path: str, all_dir: str, clear: bool):
    if (path is None) == (all_dir is None):
        raise click.UsageError("one of --path or --all-dir should be provided")

    if clear:
        delete_non_python_files()

    p = Path(path or all_dir)

    schema = {
        "type": "record",
        "name": "Employee",
        "fields": [
            {"name": "firstname", "type": "string"},
            {"name": "middlename", "type": "string"},
            {"name": "lastname", "type": "string"},
            {"name": "id", "type": "string"},
            {"name": "gender", "type": "string"},
            {"name": "salary", "type": "int"},
        ]
    }

    schema = make_avsc_object(schema)

    if p.is_dir():
        files = [file for file in p.glob("*.avro")]
    else:
        files = [p]

    for file in files:
        read_file(file, schema)



if __name__ == '__main__':
    print_avro()
