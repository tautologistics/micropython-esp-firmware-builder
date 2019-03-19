FROM ubuntu:trusty

## Paths
# Path where all code and toolchains will be placed
ARG BASE_DIR=/build

## git stuff
# Branch or tag to compile micropython from
ARG MICROPYTHON_VERSION=master
# Specific commit hash in ESP-IDF required for the ESP32 port
ARG ESP_IDF_HASH=5c88c5996dbde6208e3bec05abc21ff6cd822d26

## Misc
# Unattended installation
ARG DEBIAN_FRONTEND=noninteractive

# Install prereqs
RUN apt-get update
RUN apt-get install -y \
  autoconf \
  automake \
  bash \
  bison \
  bzip2 \
  flex \
  g++ \
  gawk \
  gcc \
  git \
  gperf \
  help2man \
  libexpat-dev \
  libffi-dev \
  libssl-dev \
  libtool \
  make \
  ncurses-dev \
  python \
  python-dev \
  python-pip \
  python-serial \
  python3-pip \
  sed \
  texinfo \
  unrar-free \
  unzip \
  wget

# Clear apt cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Create user for compilation ops
RUN useradd --no-create-home micropython

# Create folder where all source code will go
RUN mkdir $BASE_DIR

## Clone source repos
# micropython
RUN cd $BASE_DIR && git clone --recursive https://github.com/micropython/micropython.git
RUN cd $BASE_DIR && cd micropython && git checkout $MICROPYTHON_VERSION && git submodule update --init
# esp-open-sdk (ESP8266)
RUN cd $BASE_DIR && git clone --recursive https://github.com/pfalcon/esp-open-sdk.git
RUN cd $BASE_DIR/esp-open-sdk && git checkout master && git submodule update --init
# esp-idf (ESP32)
RUN cd $BASE_DIR && git clone --recursive https://github.com/espressif/esp-idf.git
RUN cd $BASE_DIR/esp-idf && git checkout $ESP_IDF_HASH && git submodule update --init
RUN pip install --upgrade setuptools
RUN pip install -r $BASE_DIR/esp-idf/requirements.txt
RUN pip3 install --upgrade setuptools
RUN pip3 install -r $BASE_DIR/esp-idf/requirements.txt
# crosstool-NG (ESP32)
RUN cd $BASE_DIR && git clone --recursive https://github.com/espressif/crosstool-NG.git
RUN cd $BASE_DIR/crosstool-NG && git submodule update --init

# Create fixed targets for built firmware
RUN ln -s micropython/ports/esp32/build/firmware.bin $BASE_DIR/firmware-esp32.bin
RUN ln -s micropython/ports/esp8266/build/firmware-combined.bin $BASE_DIR/firmware-esp8266.bin

# Set perms to compilation user
RUN chown -R micropython:micropython $BASE_DIR

# Switch to compilation user context
USER micropython

## Configure and build deps
# esp-open-sdk
RUN cd $BASE_DIR/esp-open-sdk && make STANDALONE=y
# crosstool-NG
RUN cd $BASE_DIR/crosstool-NG && ./bootstrap && ./configure --enable-local && make install \
    && ./ct-ng xtensa-esp32-elf && ./ct-ng build \
    && chmod -R u+w builds/xtensa-esp32-elf
# Add deps to path
ENV PATH=$BASE_DIR/esp-open-sdk/xtensa-lx106-elf/bin:$BASE_DIR/crosstool-NG/builds/xtensa-esp32-elf/bin:$PATH
# Set deps env vars
ENV IDF_PATH=$BASE_DIR/esp-idf
ENV ESPIDF=$BASE_DIR/esp-idf
# mpy-cross tool
RUN cd $BASE_DIR/micropython/mpy-cross && make

## Verify builds
# ESP8266
RUN cd $BASE_DIR/micropython/ports/esp8266 && make
# ESP32
RUN cd $BASE_DIR/micropython/ports/esp32 && make
