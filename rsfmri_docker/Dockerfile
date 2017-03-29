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
RUN pip install --upgrade pip
RUN pip install numpy
RUN pip install scipy
RUN pip install nibabel
RUN pip install networkx

#navigate to the tmp directory to download files
RUN cd /tmp
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

#set environment variables
ENV PATH=$PATH:$BXHBIN/bin
ENV PATH=$PATH:$BXHBIN/lib
ENV PATH=$PATH:$RSFMRI/bin

#Source FSL configuration (no bash profile exists in neurodebian so just copy over)
RUN cp /etc/fsl/5.0/fsl.sh ~/.bash_profile
RUN /bin/bash -c ". ~/.bash_profile"
#choose the current directory to be RSFMRI

RUN cd $RSFMRI/bin
WORKDIR $RSFMRI/bin

#Documented below are the attempted changes using sed to modify the original python source
#unfortunately indentation misalignments made the approach using sed difficult.
#RUN sed -i "s\#data1 = data.get_data()\#dataold = data.get_data()\g" *
#RUN sed -i "s#data1 = data.get_data()#data1 = data.get_data()\n\t\t\tif not (isinstance(data1, numpy.float32) or isinstance(data1, numpy.float64) or isinstance(data1,float)):\n\\t\t\t\tdata1.astype###(dtype=np.float64)#g" *
#RUN sed -i "s#-1:self.tr_ms#-1:long(self.tr_ms)#g" *
#RUN sed -i "s#len1:len2#long(len1):long(len2)#g" *
#RUN sed -i "s#(len1-tmpMA+tmpMA2)-1:len1+tmpMA2#long(len1-tmpMA+tmpMA2-1):long(len1+tmpMA2)#g" *
#RUN sed -i "s#(len2-tmpMA2)-1:len2+tmpMA-tmpMA2#long(len2-tmpMA2-1):long(len2+tmpMA-tmpMA2)#g" *

#sed could not effectively change file as described above - sp just create a new copy of resting_pipeline 
COPY ./src/resting_pipeline.py .

RUN cd /opt/
RUN mkdir data
RUN cd data
WORKDIR /opt/data

ENTRYPOINT ["/bin/bash", "-l"]
