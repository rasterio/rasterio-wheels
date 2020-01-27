Changes
=======

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
