Bootstrap: docker
From: ubuntu:xenial

%help
exec /opt/bin/startup.sh "-h"

%setup
cp ./src/resting_pipeline.py $SINGULARITY_ROOTFS
cp ./src/fsl_sub $SINGULARITY_ROOTFS
cp ./src/statusfeat.py $SINGULARITY_ROOTFS
cp ./src/runfeat-1.py $SINGULARITY_ROOTFS
cp ./src/make_fsl_stc.py $SINGULARITY_ROOTFS
cp ./src/startup.sh $SINGULARITY_ROOTFS
cp ./src/readme $SINGULARITY_ROOTFS
cp ./src/version $SINGULARITY_ROOTFS

%environment
export FSLDIR=/opt/fsl
export BXHVER=bxh_xcede_tools-1.11.1-lsb30.x86_64
export BXHBIN=/opt/$BXHVER
export RSFMRI=/opt/rsfmri_python
export PATH=$PATH:$BXHBIN/bin
export PATH=$PATH:$BXHBIN/lib
export PATH=$PATH:$RSFMRI/bin
export PATH=$PATH:$FSLDIR/bin
export PATH=$PATH:$FSLDIR/bin/FSLeyes
export PATH=$PATH:/opt/bin
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/.singularity.d/libs:$LD_LIBRARY_PATH

%files

%runscript
cd /opt/data
exec /opt/bin/startup.sh "$@"

%test

%post
mkdir /uaopt /extra /xdisk /opt/data /opt/bin /rsgrps
export BXHVER=bxh_xcede_tools-1.11.1-lsb30.x86_64
export BXHLOC=7384
export BXHBIN=/opt/$BXHVER
export RSFMRI=/opt/rsfmri_python
apt-get update && apt-get install -y \
	nano \
	wget \
	curl \
	lsb-core \
	python-pip \
        libx11-6 \
        libgl1 \
        libsm6 \
        libxext6 \
        libxt6 \
        mesa-common-dev \
        freeglut3-dev \
        zlib1g-dev \
        libpng-dev \
        expat \
        unzip
pip install numpy
pip install scipy
pip install nibabel
pip install networkx==1.11
cd /tmp

export LD_LIBRARY_PATH=/.singularity.d/libs:$LD_LIBRARY_PATH
cd /tmp
wget https://cmake.org/files/v3.10/cmake-3.10.0-rc1.tar.gz
tar xz -f cmake-3.10.0-rc1.tar.gz
rm cmake-3.10.0-rc1.tar.gz
cd cmake-3.10.0-rc1
./configure
make
make install
./bootstrap --prefix=/usr
make
make install
wget http://www.vtk.org/files/release/7.1/VTK-7.1.1.tar.gz
tar xz -f VTK-7.1.1.tar.gz
rm VTK-7.1.1.tar.gz
cd VTK-7.1.1
cmake .
make
make install
export FSLDIR=/opt/fsl
export PATH=${FSLDIR}/bin:${PATH}
cd /opt
curl -sSL  https://www.dropbox.com/s/fappgvj52xpfyzj/fsl-5.0.10-sources.tar.gz?dl=1 | tar zx
chmod -R 777 fsl
sed -i 's/#FSLCONFDIR/FSLCONFDIR/g' ${FSLDIR}/etc/fslconf/fsl.sh
sed -i 's/#FSLMACHTYPE/FSLMACHTYPE/g' ${FSLDIR}/etc/fslconf/fsl.sh
sed -i 's/#export FSLCONFDIR/export FSLCONFDIR /g' ${FSLDIR}/etc/fslconf/fsl.sh
. ${FSLDIR}/etc/fslconf/fsl.sh
cp -r ${FSLDIR}/config/linux_64-gcc4.8 ${FSLDIR}/config/${FSLMACHTYPE}
sed -i "s#scl enable devtoolset-2 -- c++#c++#g" $FSLDIR/config/$FSLMACHTYPE/systemvars.mk
sed -i "s#VTKDIR_INC = /home/fs0/cowboy/var/caper_linux_64-gcc4.4/VTK7/include/vtk-7.0#VTKDIR_INC = /usr/local/include/vtk-7.1/#g" $FSLDIR/config/$FSLMACHTYPE/externallibs.mk
sed -i "s#VTKDIR_LIB = /home/fs0/cowboy/var/caper_linux_64-gcc4.4/VTK7/lib#VTKDIR_LIB = /usr/local/lib/#g" $FSLDIR/config/$FSLMACHTYPE/externallibs.mk
sed -i "s#VTKSUFFIX = -7.0#VTKSUFFIX = -7.1#g" $FSLDIR/config/$FSLMACHTYPE/externallibs.mk
sed -i "s#{LIBRT}#{LIBRT} -ldl#g" $FSLDIR/src/mist-clean/Makefile
sed -i "s#lpng -lz#lpng -lz -lm#g" $FSLDIR/src/miscvis/Makefile
cd ${FSLDIR}
./build
sed -i "s#dropprivileges=1#dropprivileges=0#g" ${FSLDIR}/etc/fslconf/fslpython_install.sh
${FSLDIR}/etc/fslconf/fslpython_install.sh
cd  ${FSLDIR}/bin
wget https://fsl.fmrib.ox.ac.uk/fsldownloads/patches/eddy-patch-fsl-5.0.11/centos6/eddy_cuda7.5
chmod +x eddy_cuda7.5
wget https://fsl.fmrib.ox.ac.uk/fsldownloads/patches/eddy-patch-fsl-5.0.11/centos6/eddy_openmp
chmod +x eddy_openmp
wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fsleyes/FSLeyes-latest-ubuntu1604.zip
unzip FSLeyes-latest-ubuntu1604.zip
rm FSLeyes-latest-ubuntu1604.zip
cd /tmp
wget "http://www.nitrc.org/frs/download.php/$BXHLOC/$BXHVER.tgz"
wget "https://wiki.biac.duke.edu/_media/biac:analysis:rsfmri_python.tgz"
tar -xzf $BXHVER.tgz -C /opt
mv biac:analysis:rsfmri_python.tgz rsfmri_python.tgz
tar -xzf rsfmri_python.tgz  -C /opt
rm rsfmri_python.tgz
rm $BXHVER.tgz

mv /resting_pipeline.py /opt/bin
mv /fsl_sub $FSLDIR/bin
mv /statusfeat.py /opt/bin
mv /runfeat-1.py /opt/bin
mv /make_fsl_stc.py /opt/bin
mv /startup.sh /opt/bin
mv /readme /opt/bin
mv /version /opt/bin

echo ". $FSLDIR/etc/fslconf/fsl.sh" >> $SINGULARITY_ENVIRONMENT

