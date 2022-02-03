# Custom utilities for Rasterio wheels.
#
# Test for OSX with [ -n "$IS_OSX" ].

function fetch_unpack {
    # Fetch input archive name from input URL
    # Parameters
    #    url - URL from which to fetch archive
    #    archive_fname (optional) archive name
    #
    # Echos unpacked directory and file names.
    #
    # If `archive_fname` not specified then use basename from `url`
    # If `archive_fname` already present at download location, use that instead.
    local url=$1
    if [ -z "$url" ];then echo "url not defined"; exit 1; fi
    local archive_fname=${2:-$(basename $url)}
    local arch_sdir="${ARCHIVE_SDIR:-archives}"
    # Make the archive directory in case it doesn't exist
    mkdir -p $arch_sdir
    local out_archive="${arch_sdir}/${archive_fname}"
    # If the archive is not already in the archives directory, get it.
    if [ ! -f "$out_archive" ]; then
        # Source it from multibuild archives if available.
        local our_archive="${MULTIBUILD_DIR}/archives/${archive_fname}"
        if [ -f "$our_archive" ]; then
            ln -s $our_archive $out_archive
        else
            # Otherwise download it.
            curl --insecure -L $url > $out_archive
        fi
    fi
    # Unpack archive, refreshing contents, echoing dir and file
    # names.
    rm_mkdir arch_tmp
    install_rsync
    (cd arch_tmp && \
        untar ../$out_archive && \
        ls -1d * &&
        rsync --delete -ah * ..)
}


function build_geos {
    CFLAGS="$CFLAGS -g -O2"
    CXXFLAGS="$CXXFLAGS -g -O2"
    build_simple geos $GEOS_VERSION https://download.osgeo.org/geos tar.bz2
}


function build_jsonc {
    if [ -e jsonc-stamp ]; then return; fi
    fetch_unpack https://s3.amazonaws.com/json-c_releases/releases/json-c-${JSONC_VERSION}.tar.gz
    (cd json-c-${JSONC_VERSION} \
        && /usr/local/bin/cmake -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX . \
        && make -j4 \
        && make install)
    if [ -n "$IS_OSX" ]; then
        for lib in $(ls ${BUILD_PREFIX}/lib/libjson-c.5*.dylib); do
            install_name_tool -id $lib $lib
        done
        for lib in $(ls ${BUILD_PREFIX}/lib/libjson-c.dylib); do
            install_name_tool -id $lib $lib
        done
    fi
    touch jsonc-stamp
}


function build_proj {
    CFLAGS="$CFLAGS -g -O2"
    CXXFLAGS="$CXXFLAGS -g -O2"
    if [ -e proj-stamp ]; then return; fi
    fetch_unpack http://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz
    (cd proj-${PROJ_VERSION} \
        && ./configure --prefix=$BUILD_PREFIX \
        && make -j4 \
        && make install)
    if [ -n "$IS_OSX" ]; then
        :
    else
        strip -v --strip-unneeded ${BUILD_PREFIX}/lib/libproj.so.*
    fi
    touch proj-stamp
}


function build_sqlite {
    if [ -e sqlite-stamp ]; then return; fi
    fetch_unpack https://www.sqlite.org/2020/sqlite-autoconf-${SQLITE_VERSION}.tar.gz
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


function build_tiff {
    if [ -e tiff-stamp ]; then return; fi
    build_zlib
    build_jpeg
    ensure_xz
    fetch_unpack https://download.osgeo.org/libtiff/tiff-${TIFF_VERSION}.tar.gz
    (cd tiff-${TIFF_VERSION} \
        && mv VERSION VERSION.txt \
        && (patch -u --force < ../patches/libtiff-rename-VERSION.patch || true) \
        && ./configure \
        && make -j4 \
        && make install)
    touch tiff-stamp
}


function build_openjpeg {
    if [ -e openjpeg-stamp ]; then return; fi
    build_zlib
    build_tiff
    build_lcms2
    local cmake=$(get_cmake)
    local archive_prefix="v"
    if [ $(lex_ver $OPENJPEG_VERSION) -lt $(lex_ver 2.1.1) ]; then
        archive_prefix="version."
    fi
    local out_dir=$(fetch_unpack https://github.com/uclouvain/openjpeg/archive/${archive_prefix}${OPENJPEG_VERSION}.tar.gz)
    (cd $out_dir \
        && $cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX . \
        && make -j4 \
        && make install)
    touch openjpeg-stamp
}


function build_libwebp {
    build_simple libwebp ${LIBWEBP_VERSION} https://storage.googleapis.com/downloads.webmproject.org/releases/webp tar.gz
}


function build_nghttp2 {
    if [ -e nghttp2-stamp ]; then return; fi
    fetch_unpack https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.gz
    (cd nghttp2-${NGHTTP2_VERSION}  \
        && ./configure --enable-lib-only --prefix=$BUILD_PREFIX \
        && make -j4 \
        && make install)
    touch nghttp2-stamp
}


function build_curl {
    if [ -e curl-stamp ]; then return; fi
    CFLAGS="$CFLAGS -g -O2"
    CXXFLAGS="$CXXFLAGS -g -O2"
    build_nghttp2
    build_openssl
    local flags="--prefix=$BUILD_PREFIX --with-nghttp2=$BUILD_PREFIX --with-libz --with-ssl"
    #    fetch_unpack https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz
    (cd curl-${CURL_VERSION} \
        && LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_PREFIX/lib:$BUILD_PREFIX/lib64 ./configure $flags \
        && make -j4 \
        && make install)
    touch curl-stamp
}

function build_zstd {
    CFLAGS="$CFLAGS -g -O2"
    CXXFLAGS="$CXXFLAGS -g -O2"
    if [ -e zstd-stamp ]; then return; fi
    fetch_unpack https://github.com/facebook/zstd/archive/v${ZSTD_VERSION}.tar.gz
    if [ -n "$IS_OSX" ]; then
        sed_ere_opt="-E"
    else
        sed_ere_opt="-r"
    fi
    (cd zstd-${ZSTD_VERSION}  \
        && make -j4 PREFIX=$BUILD_PREFIX ZSTD_LEGACY_SUPPORT=0 \
        && make install SED_ERE_OPT=$sed_ere_opt)
    touch zstd-stamp
}

function build_gdal {
    if [ -e gdal-stamp ]; then return; fi

    build_curl
    build_jpeg
    build_libpng
    build_openjpeg
    build_jsonc
    build_proj
    build_sqlite
    build_expat
    build_geos
    build_hdf5
    build_netcdf
    build_zstd

    CFLAGS="$CFLAGS -g -O2"
    CXXFLAGS="$CXXFLAGS -g -O2"

    if [ -n "$IS_OSX" ]; then
        EXPAT_PREFIX=/usr
        GEOS_CONFIG="--without-geos"
    else
        EXPAT_PREFIX=$BUILD_PREFIX
        GEOS_CONFIG="--with-geos=${BUILD_PREFIX}/bin/geos-config"
    fi

    fetch_unpack http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz
    (cd gdal-${GDAL_VERSION} \
        && (patch -u -p2 --force < ../patches/4646.diff || true) \
        && ./configure \
            --with-crypto=yes \
	    --with-hide-internal-symbols \
	    --with-webp=${BUILD_PREFIX} \
            --disable-debug \
            --disable-static \
	    --disable-driver-elastic \
            --prefix=$BUILD_PREFIX \
            --with-curl=curl-config \
            --with-expat=${EXPAT_PREFIX} \
            ${GEOS_CONFIG} \
            --with-geotiff=internal \
            --with-gif \
            --with-grib \
            --with-jpeg \
            --with-libiconv-prefix=/usr \
            --with-libjson-c=${BUILD_PREFIX} \
            --with-libtiff=${BUILD_PREFIX} \
            --with-libz=/usr \
            --with-netcdf=${BUILD_PREFIX} \
            --with-openjpeg \
            --with-pam \
            --with-png \
            --with-proj=${BUILD_PREFIX} \
            --with-sqlite3=${BUILD_PREFIX} \
            --with-zstd=${BUILD_PREFIX} \
            --with-threads \
            --without-bsb \
            --without-cfitsio \
            --without-dwgdirect \
            --without-ecw \
            --without-fme \
            --without-freexl \
            --without-gnm \
            --without-grass \
            --without-ingres \
            --without-jasper \
            --without-jp2mrsid \
            --without-jpeg12 \
            --without-kakadu \
            --without-libgrass \
            --without-libgrass \
            --without-libkml \
            --without-mrf \
            --without-mrsid \
            --without-mysql \
            --without-odbc \
            --without-ogdi \
            --without-pcidsk \
            --without-pcraster \
            --without-perl \
            --without-pg \
            --without-php \
            --without-python \
            --without-qhull \
            --without-sde \
            --without-sfcgal \
            --without-xerces \
            --without-xml2 \
        && make -j4 \
        && make install)
    if [ -n "$IS_OSX" ]; then
        :
    else
        strip -v --strip-unneeded ${BUILD_PREFIX}/lib/libgdal.so.*
    fi
    touch gdal-stamp
}


function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    #if [ -n "$IS_OSX" ]; then
    #    # Update to latest zlib for OSX build
    #    build_new_zlib
    #fi

    suppress build_nghttp2

    if [ -n "$IS_OSX" ]; then
        rm /usr/local/lib/libpng*
        sudo build_openssl
    else
        build_openssl
    fi

    fetch_unpack https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz

    # Remove previously installed curl.
    rm -rf /usr/local/lib/libcurl*

    if [ -n "$IS_OSX" ]; then
        sudo build_curl
    else
        build_curl
    fi

    suppress build_libpng
    suppress build_jpeg
    suppress build_openjpeg
    suppress build_jsonc
    suppress build_proj
    suppress build_sqlite
    suppress build_expat
    suppress build_libwebp
    suppress build_geos
    suppress build_hdf5
    suppress build_netcdf
    suppress build_zstd

    suppress build_gdal
}


function run_tests {
    unset GDAL_DATA
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
        sudo apt-get install -y ca-certificates
    fi
    cp -R ../rasterio/tests ./tests
    pip install shapely
    PROJ_NETWORK=ON python -m pytest -vv tests -m "not gdalbin" -k "not test_ensure_env_decorator_sets_gdal_data_prefix and not test_tiled_dataset_blocksize_guard and not test_untiled_dataset_blocksize and not test_positional_calculation_byindex and not test_transform_geom_polygon and not test_reproject_error_propagation and not test_issue2353"
    rio --version
    rio env --formats
    python ../test_fiona_issue383.py
}


function build_wheel_cmd {
    # Update the container's auditwheel with our patched version.
    if [ -n "$IS_OSX" ]; then
	:
    else  # manylinux
        /opt/python/cp37-cp37m/bin/pip install -I "git+https://github.com/sgillies/auditwheel.git#egg=auditwheel"
    fi

    local cmd=${1:-pip_wheel_cmd}
    local repo_dir=${2:-$REPO_DIR}
    [ -z "$repo_dir" ] && echo "repo_dir not defined" && exit 1
    local wheelhouse=$(abspath ${WHEEL_SDIR:-wheelhouse})
    start_spinner
    if [ -n "$(is_function "pre_build")" ]; then pre_build; fi
    stop_spinner
    if [ -n "$BUILD_DEPENDS" ]; then
        pip install $(pip_opts) $BUILD_DEPENDS
    fi
    (cd $repo_dir && PIP_NO_BUILD_ISOLATION=0 PIP_USE_PEP517=0 $cmd $wheelhouse)
    if [ -n "$IS_OSX" ]; then
	:
    else  # manylinux
        /opt/python/cp37-cp37m/bin/pip install -I "git+https://github.com/sgillies/auditwheel.git#egg=auditwheel"
    fi
    repair_wheelhouse $wheelhouse
}
