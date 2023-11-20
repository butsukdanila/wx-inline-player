FROM ubuntu:22.04

# install dependencies
RUN apt-get update \
 && apt-get install -y \
 	curl wget git \
	make cmake \
	python3 python3-distutils python3-apt python-is-python3 \
	npm \
	openjdk-19-jre \
 && rm -rf /var/lib/apt/lists/*

# install emsdk (1.38.45)
RUN cd /root \
 && git clone https://github.com/emscripten-core/emsdk.git \
 && cd emsdk \
 && ./emsdk install latest \
 && ./emsdk activate latest

RUN echo "source /root/emsdk/emsdk_env.sh" >> /root/.bashrc \
 && echo "JAVA = '/usr/bin/java'" >> /root/emsdk/.emscripten \
 && git config --global --add safe.directory '*'