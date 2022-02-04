# rasterio-wheels

Rasterio wheel builds based on https://github.com/multi-build/multibuild.

This project builds the rasterio binary distributions that are uploaded to
PyPI. Those distributions, or "wheels", include a GDAL shared library and other
shared libraries supporting many, but not all, of GDAL's format drivers. If you
need the rarely used formats and compressors not found in these wheels, you may
find them in the conda-forge conda channel, or in Docker images published by
the GDAL project.

Wheels for x86_64 manylinux2014 and macos Pythons 3.7-3.10 are built by GitHub
Actions.

Wheels for aarch64 linux and arm64 macos are complicated by limited
availability of build instances and cross-compilation issues within GDAL's
dependencies. See the issue tracker for details.

Wheels for windows are not available. We don't have enough Windows experience
in this project yet.
