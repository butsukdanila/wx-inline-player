FROM ubuntu:22.04

# install packages
RUN apt-get update \
 && apt-get install -y \
 	sudo curl wget git make cmake \
	python3 python3-distutils python3-apt python-is-python3 \
	npm openjdk-19-jre \
 && rm -rf /var/lib/apt/lists/*

# create user
ARG USERNAME=duser
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
RUN groupadd --gid ${USER_GID} ${USERNAME} \
 && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
 && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
 && chmod 0440 /etc/sudoers.d/${USERNAME} \
 && chown -R ${USER_UID}:${USER_GID} /home/${USERNAME}

# update node
RUN npm cache clean -f \
 && npm install -g n \
 && n stable

# install emsdk
RUN cd /home/${USERNAME} \
 && git clone https://github.com/emscripten-core/emsdk.git \
 && cd emsdk \
 && ./emsdk install latest \
 && ./emsdk activate latest \
 && echo "source /home/${USERNAME}/emsdk/emsdk_env.sh" >> /home/${USERNAME}/.profile \
 && echo "JAVA = '/usr/bin/java'" >> ./.emscripten

USER ${USERNAME}