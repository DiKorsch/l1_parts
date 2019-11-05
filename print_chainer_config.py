#!/usr/bin/env python
if __name__ != '__main__': raise Exception("Do not import me!")

import chainer

print(f"Chainer version: {chainer.__version__}")
# import cupy
# cupy.show_config()
