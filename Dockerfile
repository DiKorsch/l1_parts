FROM chainer/chainer:v4.2.0-python3

RUN mkdir /code
RUN mkdir /data

WORKDIR /code

RUN apt-get update  -y && \
	apt-get install -y \
		git openssh-client \
		python3-pip \
		cython3

# install vlfeat
ADD http://www.vlfeat.org/download/vlfeat-0.9.21-bin.tar.gz vlfeat-0.9.21-bin.tar.gz
RUN tar xzf vlfeat-0.9.21-bin.tar.gz
RUN cp -v vlfeat-0.9.21/bin/glnxa64/*.so /usr/lib/x86_64-linux-gnu/
RUN mkdir /usr/include/vl
RUN cp -v vlfeat-0.9.21/vl/*.h /usr/include/vl

# clone my repos
# RUN git clone --branch gcpr2019submission \
# RUN git clone \
# 	https://github.com/DiKorsch/svm_baselines.git

# RUN git clone --branch gcpr2019submission \
# RUN git clone \
# 	https://github.com/DiKorsch/feature_extraction.git

COPY data.yaml /data

COPY requirements.txt /code
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt
