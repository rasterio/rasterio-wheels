# rasterio-wheels

This project builds the rasterio binary distributions that are uploaded to
PyPI. Those distributions, or "wheels", include a GDAL shared library and other
shared libraries supporting many, but not all, of GDAL's format drivers. If you
need the rarely used formats and compressors not found in these wheels, you may
find them in the conda-forge conda channel, or in Docker images published by
the GDAL project.

Wheels for manylinux2014_x86_64, macos_10_15_x86_64, and win_amd64 are built by GitHub
Actions. Wheels for macosx_11_0_arm64 are built by Cirrus CI.

Other platforms are out of scope at this time.
