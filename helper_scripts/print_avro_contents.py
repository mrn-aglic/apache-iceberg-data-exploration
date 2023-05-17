import io

import click
import ast
import json
import avro
from avro.datafile import DataFileWriter, DataFileReader
from avro.io import DatumWriter, DatumReader
from pathlib import Path


from avro.schema import make_avsc_object


def byteToStr(input_dict):
    str_dict = str(input_dict)
    str_dict = str_dict.replace("b'", "'").replace("'", "\"")
    return ast.literal_eval(str_dict)


@click.command()
@click.option('--path', prompt="enter the file path")
def print_avro(path: str):
    p = Path(path)

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

    with open(path, 'rb') as f:
        avro_reader = DataFileReader(f, DatumReader(schema))
        rows = [row for row in avro_reader]

        # print(rows)

        str_rows = [byteToStr(row) for row in rows]

        name = p.name.split(".avro")[0]

        with open(f"helper_scripts/{name}.json", "w") as f:
            json.dump(str_rows, f, indent=4)

    # with open(path, 'r', encoding="ISO-8859-1") as f:
    #     # bytes_writer = io.BytesIO(f)
    #
    #     reader = DatumReader(schema)
    #     decoder = avro.io.BinaryDecoder(f)
    #
    #     result = reader.read(decoder)
    #
    #     print(list(result))


if __name__ == '__main__':
    print_avro()
