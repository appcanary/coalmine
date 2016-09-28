#!/usr/bin/env python
# convert a .pickle.bz2 file from the command line into a messagepacked file

import sys
import bz2
import pickle
import msgpack

def strip_end(text, suffix):
    if not text.endswith(suffix):
        return text
    return text[:-len(suffix)]

if __name__ == "__main__":
    path = sys.argv[1]
    if not path.endswith(".pickle.bz2"):
        raise ValueError("filename must end with pickle.bz2")

    with bz2.BZ2File(path) as f:
        data = pickle.load(f)

    new_path = path[:-len(".pickle.bz2")] + ".msgpack"
    with open(new_path, "w") as f:
        msgpack.dump(data, f)


