FROM python:3.11.3-slim-buster

WORKDIR /usr/src/mergebot
RUN chmod 777 /usr/src/mergebot

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get -y upgrade && apt-get install -y python3 python3-pip git \
    p7zip-full p7zip-rar xz-utils wget curl pv jq \
    ffmpeg unzip mediainfo mkvtoolnix

# RUN curl https://rclone.org/install.sh | bash

# Change repo 
RUN echo deb http://http.us.debian.org/debian/ testing non-free contrib main > /etc/apt/sources.list && \
    apt-get -y update

# Install AOM and other dependencies
RUN apt-get install libcrypt1 libaom-dev -y

# Compile and install fresh ffmpeg from sources:
# See: https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu

RUN apt-get -y install build-essential autoconf automake cmake libtool checkinstall nasm yasm libass-dev libfreetype6-dev libsdl2-dev p11-kit libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo wget zlib1g-dev libchromaprint-dev frei0r-plugins-dev gnutls-dev ladspa-sdk libcaca-dev libcdio-paranoia-dev libcodec2-dev libfontconfig1-dev libfreetype6-dev libfribidi-dev libgme-dev libgsm1-dev libjack-dev libmodplug-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libopenjp2-7-dev libopenmpt-dev libopus-dev libpulse-dev librsvg2-dev librubberband-dev librtmp-dev libshine-dev libsmbclient-dev libsnappy-dev libsoxr-dev libspeex-dev libssh-dev libtesseract-dev libtheora-dev libtwolame-dev libv4l-dev libvo-amrwbenc-dev libvorbis-dev libvpx-dev libwavpack-dev libwebp-dev libx264-dev libx265-dev libxvidcore-dev libxml2-dev libzmq3-dev libzvbi-dev liblilv-dev libopenal-dev opencl-dev libjack-dev libavc1394-0 libavc1394-dev libiec61883-0 libiec61883-dev libbluray-dev libfdk-aac-dev libbs2b-dev libbs2b0 
RUN apt-get install tar libass-dev libtheora-dev libvorbis-dev -y && \
apt-get update && \
apt-get install libdrm-dev -y

RUN wget https://ffmpeg.org/releases/ffmpeg-6.0.tar.bz2  && \
tar -xf ffmpeg-6.0.tar.bz2  && \
rm ffmpeg-6.0.tar.bz2  && \
cd ffmpeg-6.0  && \
./configure disable-static disable-stripping enable-avisynth enable-chromaprint enable-frei0r enable-gmp enable-gnutls enable-gpl enable-ladspa enable-libaom enable-libass enable-libbluray enable-libbs2b enable-libcaca enable-libcdio enable-libcodec2 enable-libdrm enable-libfdk-aac enable-libfontconfig enable-libfreetype enable-libfribidi enable-libgme enable-libgsm enable-libiec61883 enable-libjack enable-libmodplug enable-libmp3lame enable-libopencore-amrnb enable-libopencore-amrwb enable-libopenjpeg enable-libopenmpt enable-libopus enable-libpulse enable-librsvg enable-librtmp enable-librubberband enable-libshine enable-libsnappy enable-libsoxr enable-libspeex enable-libssh enable-libtesseract enable-libtheora enable-libtwolame enable-libv4l2 enable-libvo-amrwbenc enable-libvorbis enable-libvpx enable-libwavpack enable-libwebp enable-libx264 enable-libx265 enable-libxml2 enable-libxvid enable-libzmq enable-libzvbi enable-lv2 enable-nonfree enable-openal enable-opencl enable-opengl enable-sdl2 enable-shared enable-small enable-version3 extra-version=0+deb11u2 incdir=/usr/include/x86_64-linux-gnu libdir=/usr/lib/x86_64-linux-gnu --toolchain=hardened  && \
make  && \
make -j8  && \
make install  && \
cp ffmpeg /usr/bin/  && \
make distclean  && \
hash -r  && \
ffmpeg 2>&1 | head -n1

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

RUN chmod +x start.sh
CMD ["bash","start.sh"]
