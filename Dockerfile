FROM neurodebian:xenial
MAINTAINER Chidi Ugonna<chidiugonna@email.arizona.edu>

# install FSL
#Making fsl-complete available as it is no longer contribution-free
#Reference: http://lists.alioth.debian.org/pipermail/neurodebian-users/2016-April/001052.html 
RUN echo 'fsl-complete is not contribution-free. making it available for install'
RUN sed -i -e 's,main$,main contrib non-free,g' /etc/apt/sources.list.d/neurodebian.sources.list
RUN apt-get update && apt-get install -y \
	fsl-complete \
	wget \
	lsb-core \
	python-pip 

#install pip, numpy, nibabel, scipy, networkx
RUN pip install numpy
RUN pip install scipy
RUN pip install nibabel
RUN pip install networkx==1.11
RUN pip install pyBIDS

#navigate to the tmp directory to download files
WORKDIR /tmp
#for 32 bit use = bxh_xcede_tools-1.11.1-lsb30.i386
ENV BXHVER bxh_xcede_tools-1.11.1-lsb30.x86_64
#for 32 bit use 7385
ENV BXHLOC 7384
RUN wget "http://www.nitrc.org/frs/download.php/$BXHLOC/$BXHVER.tgz"
RUN wget "https://wiki.biac.duke.edu/_media/biac:analysis:rsfmri_python.tgz"

#extract BXH and rsFMRi to /opt 
RUN tar -xzf $BXHVER.tgz -C /opt

#rename and extract - ignore extended header information
RUN mv biac:analysis:rsfmri_python.tgz rsfmri_python.tgz
RUN tar -xzf rsfmri_python.tgz  -C /opt

ENV BXHBIN /opt/$BXHVER
ENV RSFMRI /opt/rsfmri_python
ENV FSLDIR /usr/share/fsl/5.0
#set environment variables
ENV PATH=$PATH:$BXHBIN/bin
ENV PATH=$PATH:$BXHBIN/lib
ENV PATH=$PATH:$RSFMRI/bin
ENV PATH=$PATH:$FSLDIR/bin

RUN mkdir -p /opt/bin
RUN chmod -R 777 /opt
WORKDIR /opt/bin
COPY ./src/resting_pipeline.py .
COPY ./src/startup.sh .
COPY ./src/runfeat-1.py .
COPY ./src/statusfeat.py .
COPY ./src/make_fsl_stc.py .
COPY ./src/fsl_sub $FSLDIR/bin
COPY ./src/readme .
COPY ./src/version .

RUN mkdir -p /opt/data
WORKDIR /opt/data

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    mkdir -p /etc/sudoers.d && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

ENV USER developer
ENV HOME /home/developer
#Source FSL configuration (no bash profile exists in neurodebian so just copy over)
RUN cp /etc/fsl/5.0/fsl.sh ~/.bash_profile
RUN /bin/bash -c ". ~/.bash_profile"
RUN echo ". ~/.bash_profile" >> ~/.bashrc


ENTRYPOINT ["/opt/bin/startup.sh"]
CMD ["more /opt/bin/readme"]
