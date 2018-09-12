#!/usr/bin/env python
""" Adds a build number to passed wheel filenames

Usage:

    python add_build.py <build_tag> <whl_fname> [<whl_fname> ...]

E.g.

    python add_build.py 1 h5py-2.6.0-*whl

This will give you output like so::

    Copying h5py-2.6.0-cp27-cp27m-manylinux1_i686.whl to h5py-2.6.0-1-cp27-cp27m-manylinux1_i686.whl
    Copying h5py-2.6.0-cp27-cp27m-manylinux1_x86_64.whl to h5py-2.6.0-1-cp27-cp27m-manylinux1_x86_64.whl
    Copying h5py-2.6.0-cp27-cp27mu-manylinux1_i686.whl to h5py-2.6.0-1-cp27-cp27mu-manylinux1_i686.whl
    Copying h5py-2.6.0-cp27-cp27mu-manylinux1_x86_64.whl to h5py-2.6.0-1-cp27-cp27mu-manylinux1_x86_64.whl
    Copying h5py-2.6.0-cp34-cp34m-manylinux1_i686.whl to h5py-2.6.0-1-cp34-cp34m-manylinux1_i686.whl
    Copying h5py-2.6.0-cp34-cp34m-manylinux1_x86_64.whl to h5py-2.6.0-1-cp34-cp34m-manylinux1_x86_64.whl
    Copying h5py-2.6.0-cp35-cp35m-manylinux1_i686.whl to h5py-2.6.0-1-cp35-cp35m-manylinux1_i686.whl
    Copying h5py-2.6.0-cp35-cp35m-manylinux1_x86_64.whl to h5py-2.6.0-1-cp35-cp35m-manylinux1_x86_64.whl
"""
from __future__ import print_function

import sys
from os.path import split as psplit, join as pjoin
from shutil import copyfile

from wheel.install import WheelFile


def main():
    build_tag = sys.argv[1]
    for wheel_fname in sys.argv[2:]:
        path, fname = psplit(wheel_fname)
        wf = WheelFile(fname)
        parsed = wf.parsed_filename.groupdict()
        parsed['build'] = build_tag
        out_fname = '{name}-{ver}-{build}-{pyver}-{abi}-{plat}.whl'.format(
            **parsed)
        out_path = pjoin(path, out_fname)
        print('Copying {} to {}'.format(wheel_fname, out_path))
        copyfile(wheel_fname, out_path)


if __name__ == '__main__':
    main()
