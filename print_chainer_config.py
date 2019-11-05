#!/usr/bin/env python
if __name__ != '__main__': raise Exception("Do not import me!")

import chainer
import cupy

print(f"Chainer version: {chainer.__version__}")
cupy.show_config()
