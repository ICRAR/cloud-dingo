#!/bin/bash

set -ex

yum -y install \
    boost \
    cppunit \
    fftw3 \
    gsl \
    hdf5 \
    htop \
    lapack.x86_64 \
    libffi \
    log4cxx \
    openblas-devel \
    open-mpi \
    openssl \
    patch \
    python \
    python-pip \
    python2-numpy \
    readline \
    xerces-c \
    wcslib
