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
    if [ -n "$IS_OSX" ]; then
        :
    else
        fetch_unpack https://github.com/libexpat/libexpat/releases/download/R_2_2_6/expat-${EXPAT_VERSION}.tar.bz2
        (cd expat-${EXPAT_VERSION} \
            && ./configure --prefix=$BUILD_PREFIX \
            && make -j4 \
            && make install)
    fi
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
        && make -j4 \
        && make install)
    touch openjpeg-stamp
}


function build_tiff {
    build_zlib
    build_jpeg
    build_simple tiff $TIFF_VERSION https://download.osgeo.org/libtiff
}


function build_hdf5 {
    if [ -e hdf5-stamp ]; then return; fi
    build_zlib
    # libaec is a drop-in replacement for szip
    build_libaec
    local hdf5_url=https://support.hdfgroup.org/ftp/HDF5/releases
    local short=$(echo $HDF5_VERSION | awk -F "." '{printf "%d.%d", $1, $2}')
    fetch_unpack $hdf5_url/hdf5-$short/hdf5-$HDF5_VERSION/src/hdf5-$HDF5_VERSION.tar.gz
    (cd hdf5-$HDF5_VERSION \
        && ./configure --enable-shared --enable-build-mode=production --with-szlib=$BUILD_PREFIX --prefix=$BUILD_PREFIX \
        && make -j4 \
        && make install)
    touch hdf5-stamp
}


function build_curl {
    if [ -e curl-stamp ]; then return; fi
    local flags="--prefix=$BUILD_PREFIX"
    if [ -n "$IS_OSX" ]; then
        flags="$flags --with-darwinssl"
    else  # manylinux
        flags="$flags --with-ssl"
        build_openssl
    fi
    fetch_unpack https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz
    (cd curl-${CURL_VERSION} \
        && if [ -z "$IS_OSX" ]; then \
        LIBS=-ldl ./configure $flags; else \
        ./configure $flags; fi\
        && make -j4 CFLAGS=-Wno-error \
        && make install)
    touch curl-stamp
}


function build_bundled_deps {
    if [ -n "$IS_OSX" ]; then
        curl -fsSL -o /tmp/deps.zip https://github.com/sgillies/rasterio-wheels/files/2350174/gdal-deps.zip
        (cd / && sudo unzip -o -q /tmp/deps.zip)
        DEPS_PREFIX=/gdal
        touch geos-stamp && touch hdf5-stamp && touch netcdf-stamp
    else
        DEPS_PREFIX=$BUILD_PREFIX
        start_spinner
        suppress build_geos
        suppress build_hdf5
        suppress build_netcdf
        stop_spinner
    fi
}


function build_gdal {
    if [ -e gdal-stamp ]; then return; fi
    build_jpeg
    build_tiff
    build_libpng
    build_openjpeg
    build_jsonc
    build_proj
    build_sqlite
    build_curl
    build_expat
    build_bundled_deps

    if [ -n "$IS_OSX" ]; then
        EXPAT_PREFIX="/usr"
    else
        EXPAT_PREFIX=$BUILD_PREFIX
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
            --without-bsb \
            --without-python \
            --with-freexl=no \
            --with-netcdf=${DEPS_PREFIX}/bin/nc-config \
            --with-openjpeg=${BUILD_PREFIX} \
            --with-libtiff=${BUILD_PREFIX}/tiff \
            --with-jpeg \
            --with-gif \
            --with-png \
            --with-geotiff=internal \
            --with-sqlite3=${BUILD_PREFIX}/sqlite \
            --with-pcraster=no \
            --with-pcidsk=no \
            --with-grib \
            --with-pam \
            --with-geos=${DEPS_PREFIX}/bin/geos-config \
            --with-proj=${BUILD_PREFIX}/proj4 \
            --with-expat=${EXPAT_PREFIX} \
            --with-libjson-c=${BUILD_PREFIX} \
            --with-libiconv-prefix=/usr \
            --with-libz=/usr \
            --with-curl=${BUILD_PREFIX}/bin/curl-config \
        && make -j4 --quiet \
        && make install)
    touch gdal-stamp
}


function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    #if [ -n "$IS_OSX" ]; then
    #    # Update to latest zlib for OSX build
    #    build_new_zlib
    #fi

    build_bundled_deps
    start_spinner
    suppress build_jpeg
    suppress build_tiff
    suppress build_libpng
    suppress build_openjpeg
    suppress build_jsonc
    suppress build_proj
    suppress build_sqlite
    suppress build_curl
    suppress build_expat
    build_gdal
    stop_spinner
}


function run_tests {
    unset PROJ_LIB
    if [ -n "$IS_OSX" ]; then
        export PATH=$PATH:${BUILD_PREFIX}/bin
        export LC_ALL=en_US.UTF-8
        export LANG=en_US.UTF-8
    else
        export LC_ALL=C.UTF-8
        export LANG=C.UTF-8
        export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
        sudo apt-get update
        sudo apt-get install -y gdal-bin ca-certificates
    fi
    cd ../rasterio
    mkdir -p /tmp/rasterio
    cp -R tests /tmp/rasterio
    cd /tmp/rasterio
    python -m pytest -vv tests
    rio --version
    rio env --formats
}
