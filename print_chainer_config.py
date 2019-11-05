#!/usr/bin/env python
if __name__ != '__main__': raise Exception("Do not import me!")

import chainer
print(f"Chainer version: {chainer.__version__}")

try:
	import cupy
	cupy.show_config()
except Exception as e:
	print("cupy could not be imported! Do you work in NVIDIA environment?!")
	pass
