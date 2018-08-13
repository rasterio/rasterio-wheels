# Custom utilities for Rasterio wheels.
#
# Test for OSX with [ -n "$IS_OSX" ].

ARCHIVE_SDIR=rasterio
MACOSX_DEPLOYMENT_TARGET=10.9

# Package versions for fresh source builds.
# Copied from Pillow wheels project.
LIBPNG_VERSION=1.6.35
ZLIB_VERSION=1.2.11
JPEG_VERSION=9c
# OPENJPEG_VERSION=2.1
TIFF_VERSION=4.0.9
LIBWEBP_VERSION=1.0.0

# Specific to Rasterio
OPENJPEG_VERSION=2.3.0
GEOS_VERSION=3.6.2
JSONC_VERSION=0.12
PROJ_VERSION=4.9.3
SQLITE_VERSION=sqlite-autoconf-3240000
GDAL_VERSION=2.2.4


function build_geos {
    build_simple geos $GEOS_VERSION https://download.osgeo.org/geos tar.bz2
}


function build_jsonc {
    local old_cflags=$CFLAGS
    export CFLAGS="${old_cflags} -Wno-error=unused-command-line-argument"
    build_simple json-c $JSONC_VERSION https://s3.amazonaws.com/json-c_releases/releases tar.gz
    export CFLAGS=$old_cflags
}


function build_proj {
    if [ -e proj-stamp ]; then return; fi
    fetch_unpack http://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz
    (cd proj-${PROJ_VERSION} \
        && patch -u -p1 < patches/bd6cf7d527ec88fdd6cc3f078387683d683d0445.diff \
        && ./configure --prefix=$BUILD_PREFIX \
        && make -j4 \
        && make install)
    touch proj-stamp
}


function build_sqlite {
    build_simple sqlite $SQLITE_VERSION https://www.sqlite.org/2018 tar.gz
}


function build_gdal {
    if [ -e gdal-stamp ]; then return; fi
    fetch_unpack http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz
    (cd gdal-${GDAL_VERSION} \
        && ./configure \
            --prefix=$BUILD_PREFIX \
            --with-threads \
            --disable-debug \
            --disable-static \
            --without-grass \
            --without-libgrass \
            --without-jpeg12 \
            --without-jasper \
            --without-python \
            --with-netcdf=${BUILD_PREFIX}/netcdf \
            --with-openjpeg=${BUILD_PREFIX}/openjpeg \
            --with-libtiff=${BUILD_PREFIX}/tiff \
            --with-webp=${BUILD_PREFIX}/webp \
            --with-jpeg \
            --with-gif \
            --with-png \
            --with-geotiff=internal \
            --with-sqlite3=${BUILD_PREFIX}/sqlite \
            --with-pcraster=internal \
            --with-pcraster=internal \
            --with-pcidsk=internal \
            --with-bsb \
            --with-grib \
            --with-pam \
            --with-geos=${BUILD_PREFIX}/bin/geos-config \
            --with-static-proj4=${BUILD_PREFIX}/proj4 \
            --with-expat=/usr \
            --with-libjson-c=${BUILD_PREFIX}/json-c \
            --with-libiconv-prefix=/usr \
            --with-libz=/usr \
            --with-curl=curl-config \
        && make -j4 \
        && make install)
    touch gdal-stamp
}


function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    if [ -n "$IS_OSX" ]; then
        # Update to latest zlib for OSX build
        build_new_zlib
    fi
    build_jpeg
    build_tiff
    build_libpng
    build_openjpeg

#    if [ -n "$IS_OSX" ]; then
#        # Fix openjpeg library install id
#        # https://code.google.com/p/openjpeg/issues/detail?id=367
#        install_name_tool -id $BUILD_PREFIX/lib/libopenjp2.7.dylib $BUILD_PREFIX/lib/libopenjp2.2.1.0.dylib
#    fi

    build_libwebp
    build_geos
    build_jsonc
    build_proj
    build_netcdf
    build_sqlite
}


function run_tests {
    # Runs tests on installed distribution from an empty directory
    cd ../rasterio && python -m pytest -vv
}
