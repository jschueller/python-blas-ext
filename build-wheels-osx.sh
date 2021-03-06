#!/bin/sh

set -e -x

PYVERD=3.7
TAG=cp37-cp37m-macosx_10_10_x86_64
VERSION=1.0

wget --no-check-certificate https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -P /tmp
bash /tmp/Miniconda3-latest-MacOSX-x86_64.sh -b -p ${HOME}/miniconda
export PATH="${HOME}/miniconda/bin:${PATH}"
conda config --add channels conda-forge
conda install -y openblas delocate pip

python setup.py build
python setup.py install

# copy metadata
mkdir ${HOME}/miniconda/lib/python${PYVERD}/site-packages/myModule-${VERSION}.dist-info
cp METADATA WHEEL ${HOME}/miniconda/lib/python${PYVERD}/site-packages/myModule-${VERSION}.dist-info
touch ${HOME}/miniconda/lib/python${PYVERD}/site-packages/myModule-${VERSION}.dist-info/RECORD

cd ${HOME}/miniconda/lib/python${PYVERD}/site-packages
otool -L myModule/myModule.cpython-37m-darwin.so
install_name_tool -id "@rpath/myModule.cpython-37m-darwin.so" myModule/myModule.cpython-37m-darwin.so

# create archive
zip -r /tmp/myModule-${VERSION}-${TAG}.whl myModule myModule-${VERSION}.dist-info

delocate-listdeps /tmp/myModule-${VERSION}-${TAG}.whl
delocate-wheel /tmp/myModule-${VERSION}-${TAG}.whl
delocate-listdeps --all /tmp/myModule-${VERSION}-${TAG}.whl

otool -l ${HOME}/miniconda/lib/libopenblas.dylib

# missing libs
mkdir myModule/.dylibs
for libname in libquadmath.0 libgcc_s.1 libc++abi.1 libgfortran.3
do
  cp ${HOME}/miniconda/lib/${libname}.dylib myModule/.dylibs
  zip -u /tmp/myModule-${VERSION}-${TAG}.whl myModule/.dylibs/${libname}.dylib
done

cd
rm -r ${HOME}/miniconda
bash /tmp/Miniconda3-latest-MacOSX-x86_64.sh -b -p ${HOME}/miniconda
conda install -y python=${PYVERD} pip

pip install myModule --no-index -f /tmp/
python -c "import myModule; myModule.helloworld()"


