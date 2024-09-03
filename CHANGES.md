Changes
=======

## 2024-09-03

* GDAL 3.9.2 (3.9.1 on Windows)
* PROJ 9.4.1
* Curl 8.8.0

## 2023-10-19

Library version changes:

* A local gdal overlay port for vcpkg has been added.
* GDAL 3.6.4 is patched in the PyPI wheels to fix the potential GTiff
  multithreading deadlock reported in
  https://github.com/OSGeo/gdal/issues/8470.

## 2023-10-11

Library version changes:

* Update curl to 8.4.0 to address CVE-2023-38545 and CVE-2023-38546 (#112).
* Update vcpkg to commit b40de44891dc1cab11d4722094ae44807a837b98 (#112).

## 2023-10-09

Python version changes:

* Python 3.12 has been added

Library version changes:

* Update libwebp to 1.3.2 to address CVE-2023-4863.

## 2023-06-26

* Patch GDAL 3.6.4 for issues #7962 and #7967.

## 2023-02-13

* Patch for GDAL issue #7170.
* PROJ symbols are renamed to avoid conflicts with other modules that may link
  libproj.
* Belatedly, Cirrus CI configuration has been added to build macos arm64
  wheels.

## 2022-11-16

Library version changes:

* GDAL 3.5.3
* GEOS 3.11.1

## 2022-10-11

Library version changes:

* GDAL 3.5.2
* GEOS 3.11.0

Python version changes:

* Python 3.11 has been added

## 2022-08-17

* Ensure WebP and ZSTD codecs are availble to libtiff (#89).

Library version changes:

* PROJ 9.0.1

## 2022-08-10

* Ensure zstd is built before tiff (#87).

Library version changes:

* GDAL 3.5.1 for Linux, macOS, and Windows

## 2022-05-20

Library version changes:

* GDAL 3.5.0
* PROJ 9.0.0

## 2022-04-20

Library version changes:

* GDAL 3.4.2
* HDF5 1.12.1

## 2022-02-04

Library version changes:

* GDAL 3.4.1.
* GEOS 3.10.2.
* PROJ 8.2.1.

Changes:

* Openssl, curl, nghttp2 are compiled from source for macos (#77).

## 2022-01-12

Wheels for x86_64 macos and manylinux2014 are now built using GitHub Actions.
We do not yet have any solutions for arm64 macos or linux wheels, or Windows
wheels.

Multibuild has been updated to commit 3903f7f.

Library version changes:

* Curl is updated to 7.80.0.
* Nghttp2 is updated to 1.46.0.
* OpenJPEG is updated to 2.4.0.

## 2021-10-14

* Apply patch for GDAL PR #4646.

## 2021-09-29

Major changes!

* Dropping manylinux1 and switching to manylinux2014 unlocks upgrades to all of
  GDAL's dependencies. We can now build and link current versions of curl and
  openssl, for example.
* PROJ is updated to 8.1.1.
* Curl is updated to 7.79.1.
* json-c is updated to 0.15.
* Nghttp2 is updated to 1.45.1.
* Zstd is updated to 1.5.0.
* OpenSSL is updated to 1.1.1l.
* GDAL and PROJ now link the same external libtiff version 4.3.0.

## 2021-09-07

* Update GDAL to 3.3.2.

## 2021-06-17

* Apply patch for GDAL PR #4003.

## 2021-05-26

* Update GEOS to 3.9.1.
* Update GDAL to 3.3.0.
* Apply patch for GDAL PR #3786.

## 2021-04-26

* Update GDAL to 3.2.2.

## 2020-10-25

* Patch GDAL 2.4.4 to get the fix for GDAL #3101 and rasterio #2022.

## 2020-09-29

* Patch GDAL 2.4.4 to get the fix in GDAL PR #2510.
* Update to the lastest multibuild (commit bc8e01e).
* Continue to use OpenSSL 1.0.2u.

## 2020-09-14

* Upgrade sqlite to 3.33.
* Patch GDAL 2.4.4 to fix issues with VRT overviews and background values.

## 2020-06-18

* Disable GEOS support in the GDAL library builds for OS X to prevent conflicts
  with shapely wheels on PyPI.
* Test rasterio and shapely wheels together to check for this conflict.

## 2020-05-06

* Ensure that shared libraries in repaired wheels have a "rasterio" tag in
  SONAME to prevent conflicts with librairies in fiona wheels (#44).
* Prevent HDF5 errors from printing to terminal (#39).
* Patch GDAL to fix /vsis3 cache bug (#43).
* Update netCDF to 4.6.2 (#41).

## 2019-01-27

* Update multibuild commit to 6b0bbd5 for pip 20 support.
* Update GEOS version to 3.8.0.
* Update GDAL version to 2.4.4 and remove patch for 2.4.3.
* Update WebP to 1.0.3.

## 2019-12-06

* Build PROJ with the proj-datumgrid-1.8 package (#33).

## 2019-12-05

* Add 64-bit manylinux1 and macosx Python 3.8 builds.
* Build HDF5, GEOS, and NetCDF for OS X insteading of using pre-built versions.
  This increases our build time to ~75 minutes, but Travis CI has graciously
  increased the limit for this project to 90.
* Update multibuild commit to 4491026 for Python 3.8 support.

## 2019-11-13

* GDAL version 2.4.3 with patch from https://github.com/OSGeo/gdal/pull/2012.
* Cython 0.29.14

## 2019-08-06

* GDAL 2.4.2
* Multibuild commit is 951b6c6

## 2018-10-31

* Downgrade curl to 7.54 (#8).

## 2018-10-16

* Patch GDAL 2.3.2 to allow AWS errors to fully surface (#7).

## 2018-10-10

* GDAL 2.3.2
* Supports Python 3.4 on 64-bit Linux

## 2018-09-12

* Multibuild commit is 9cc15c7
* GEOS version 3.6.2
* PROJ 4.9.3 (patched)
* OpenJPEG 2.3.0
* GDAL 2.3.1 (patched)
* Cython 0.28.3
* Minimum MacOS version is 10.9
* Supports Python 2.7, 3.5. 3.6, and 3.7 on 64-bit Linux
* Supports Python 2.7, 3.4, 3.5, 3.6, and 3.7 on OSX (Xcode 9.4)
