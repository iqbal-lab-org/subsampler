# If you want to use this container, it is simpler to just pull it:
#   docker pull leandroishilima/subsampler:pandora_paper_tag1

# This container has subsampling software to be used by the pandora_analysis_pipeline
# to build: sudo docker build . -t leandroishilima/subsampler:pandora_paper_tag1
FROM ubuntu:bionic

ARG filtlong_version="0.2.0"
ARG rasusa_version="0.3.0"

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# install basic dependencies
RUN apt update && \
    apt install -y software-properties-common && \
    apt-add-repository universe && \
    apt update && \
    apt install -y wget build-essential zlib1g-dev


# ================================
# INSTALL filtlong
# ================================
RUN wget -O - "https://github.com/rrwick/Filtlong/archive/v${filtlong_version}.tar.gz" | tar xzf - && \
    cd Filtlong-${filtlong_version} && \
    make -j4
ENV PATH="/Filtlong-${filtlong_version}/bin:${PATH}"


# ================================
# INSTALL rasusa
# ================================
RUN wget "https://github.com/mbhall88/rasusa/releases/download/${rasusa_version}/rasusa-${rasusa_version}-x86_64-unknown-linux-musl.tar.gz" -O - | tar -xzf - && \
    mv rasusa /usr/bin/
