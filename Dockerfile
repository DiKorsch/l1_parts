# copied from https://github.com/chainer/chainer/blob/v6.7.0/docker/python3/Dockerfile
# updated for CUDA v10.1 and Ubuntu 18.04

# FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04 AS l1_parts
FROM dikorsch/chainer-cuda101-opencv4.1.1

ENV EXTRACTOR_FOLDER="feature_extraction"
ENV ESTIMATOR_FOLDER="l1_part_estimatoin"
ENV SVM_TRAINING="svm_training"
ENV PIP="pip3"

# install vlfeat
WORKDIR /home
ADD http://www.vlfeat.org/download/vlfeat-0.9.21-bin.tar.gz vlfeat-0.9.21-bin.tar.gz
RUN tar xzf vlfeat-0.9.21-bin.tar.gz && \
	cp -v vlfeat-0.9.21/bin/glnxa64/*.so /usr/lib/x86_64-linux-gnu/ && \
	mkdir /usr/include/vl && \
	cp -v vlfeat-0.9.21/vl/*.h /usr/include/vl && \
	rm -r vlfeat-0.9.21 vlfeat-0.9.21-bin.tar.gz

WORKDIR /home/repos
# clone my repos

RUN git clone https://github.com/DiKorsch/feature_extraction.git ${EXTRACTOR_FOLDER}
# RUN cd ${EXTRACTOR_FOLDER}; git checkout gcpr2019submission -b gcpr2019submission; cd ..

RUN git clone https://github.com/DiKorsch/l1_part_estimation.git ${ESTIMATOR_FOLDER}
# RUN cd ${ESTIMATOR_FOLDER}; git checkout gcpr2019submission -b gcpr2019submission; cd ..

RUN git clone https://github.com/DiKorsch/svm_training.git ${SVM_TRAINING}
# RUN cd ${SVM_TRAINING}; git checkout gcpr2019submission -b gcpr2019submission; cd ..

COPY requirements.txt /home/repos
RUN ${PIP} install -r requirements.txt

RUN mkdir /data
WORKDIR /home/code
RUN chmod -R go+w /home
