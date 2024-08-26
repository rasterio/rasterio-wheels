LIBPNG_VERSION=1.6.35
ZLIB_VERSION=1.2.11
LIBDEFLATE_VERSION=1.7
JPEG_VERSION=9f
LIBWEBP_VERSION=1.3.2
OPENJPEG_VERSION=2.4.0
GEOS_VERSION=3.11.1
JSONC_VERSION=0.15
SQLITE_VERSION=3330000
PROJ_VERSION=9.4.1
GDAL_VERSION=3.9.2
CURL_VERSION=8.8.0
NGHTTP2_VERSION=1.46.0
EXPAT_VERSION=2.2.6
HDF5_VERSION=1.12.1
NETCDF_VERSION=4.6.2
ZSTD_VERSION=1.5.0
TIFF_VERSION=4.3.0
LERC_VERSION=4.0.0
OPENSSL_DOWNLOAD_URL=https://www.openssl.org/source/
OPENSSL_ROOT=openssl-1.1.1w
OPENSSL_HASH=cf3098950cb4d853ad95c0841f1f9c6d3dc102dccfcacd521d93925208b76ac8
PCRE_VERSION=10.44
export MACOSX_DEPLOYMENT_TARGET=10.15
export GDAL_CONFIG=/usr/local/bin/gdal-config
export PACKAGE_DATA=1
export PROJ_DATA=/usr/local/share/proj
export AUDITWHEEL_EXTRA_LIB_NAME_TAG=rasterio
export TEST_DEPENDS="oldest-supported-numpy attrs pytest click mock boto3 packaging hypothesis fsspec aiohttp requests"
