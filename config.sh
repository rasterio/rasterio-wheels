# Custom utilities for Rasterio wheels.
#
# Test for OSX with [ -n "$IS_OSX" ].


function build_geos {
    build_simple geos $GEOS_VERSION https://download.osgeo.org/geos tar.bz2
}


function build_jsonc {
    build_simple json-c $JSONC_VERSION https://s3.amazonaws.com/json-c_releases/releases tar.gz
}


function build_proj {
    if [ -e proj-stamp ]; then return; fi
    fetch_unpack http://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz
    (cd proj-${PROJ_VERSION} \
        && patch -u -p1 < ../patches/bd6cf7d527ec88fdd6cc3f078387683d683d0445.diff \
        && ./configure --prefix=$BUILD_PREFIX \
        && make -j4 \
        && make install)
    touch proj-stamp
}


function build_sqlite {
    if [ -e sqlite-stamp ]; then return; fi
    fetch_unpack https://www.sqlite.org/2018/sqlite-autoconf-${SQLITE_VERSION}.tar.gz
    (cd sqlite-autoconf-${SQLITE_VERSION} \
        && ./configure --prefix=$BUILD_PREFIX \
        && make -j4 \
        && make install)
    touch sqlite-stamp
}


function build_expat {
    if [ -e expat-stamp ]; then return; fi
    fetch_unpack https://github.com/libexpat/libexpat/releases/download/R_2_2_6/expat-${EXPAT_VERSION}.tar.bz2
    (cd expat-${EXPAT_VERSION} \
        && ./configure --prefix=$BUILD_PREFIX \
        && make -j4 \
        && make install)
    touch expat-stamp
}


function get_cmake {
    local cmake=cmake
    if [ -n "$IS_OSX" ]; then
        brew install cmake > /dev/null
    else
        fetch_unpack https://www.cmake.org/files/v3.12/cmake-3.12.1.tar.gz > /dev/null
        (cd cmake-3.12.1 \
            && ./bootstrap --prefix=$BUILD_PREFIX > /dev/null \
            && make -j4 > /dev/null \
            && make install > /dev/null)
        cmake=/usr/local/bin/cmake
    fi
    echo $cmake
}


function build_openjpeg {
    if [ -e openjpeg-stamp ]; then return; fi
    build_zlib
    build_libpng
    build_tiff
    build_lcms2
    local cmake=$(get_cmake)
    local archive_prefix="v"
    if [ $(lex_ver $OPENJPEG_VERSION) -lt $(lex_ver 2.1.1) ]; then
        archive_prefix="version."
    fi
    local out_dir=$(fetch_unpack https://github.com/uclouvain/openjpeg/archive/${archive_prefix}${OPENJPEG_VERSION}.tar.gz)
    (cd $out_dir \
        && $cmake -DBUILD_THIRDPARTY:BOOL=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX . \
        && make install)
    touch openjpeg-stamp
}


function build_gdal {
    if [ -e gdal-stamp ]; then return; fi

    start_spinner

    suppress build_jpeg
    suppress build_tiff
    suppress build_libpng
    suppress build_openjpeg
    suppress build_libwebp
    suppress build_geos
    suppress build_jsonc
    suppress build_proj
    suppress build_netcdf
    suppress build_sqlite
    suppress build_curl
    suppress build_expat

    stop_spinner

    if [ -n "$IS_OSX" ]; then
        export EXPAT_PREFIX="/usr"
    else
        export EXPAT_PREFIX=$BUILD_PREFIX
    fi

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
            --with-openjpeg=${BUILD_PREFIX} \
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
            --with-expat=${EXPAT_PREFIX} \
            --with-libjson-c=${BUILD_PREFIX}/json-c \
            --with-libiconv-prefix=/usr \
            --with-libz=/usr \
            --with-curl=${BUILD_PREFIX}/bin/curl-config \
        && make \
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

    build_gdal && /usr/local/bin/gdal-config --formats
}


function run_tests {
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
    sudo apt-get install -y gdal-bin
    cd ../rasterio
    mkdir -p /tmp/rasterio
    cp -R tests /tmp/rasterio
    cd /tmp/rasterio
    python -m pytest -vv tests
    rio --version
    rio env --formats
}
