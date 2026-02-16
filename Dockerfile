FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    curl \
    git \
    vim \
    file \
    build-essential \
    csh \
    gfortran \
    m4 \
    perl \
    libpng-dev \
    netcdf-bin \
    libnetcdff-dev \
    libopenmpi-dev \
    libhdf5-openmpi-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN useradd -m -s /bin/bash wrfuser && \
    echo "wrfuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER wrfuser
WORKDIR /home/wrfuser

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /home/wrfuser/miniconda && \
    rm ~/miniconda.sh
ENV PATH="/home/wrfuser/miniconda/bin:$PATH"
RUN conda init bash

RUN conda install -n base -c conda-forge --override-channels conda-anaconda-tos -y && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

RUN conda install -n base conda-libmamba-solver -y && \
    conda config --set solver libmamba

RUN conda create -n pywrf -c conda-forge -y python=3.11 wrf-python netcdf4 cartopy matplotlib xarray
RUN conda create -n ferret -c conda-forge -y pyferret ferret_datasets

RUN mkdir /home/wrfuser/data

RUN git clone https://github.com/bakamotokatas/WRF-Install-Script.git
