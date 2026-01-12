# Stage 1: Cloner (temporary, discarded after build)
FROM debian:trixie-20251117-slim AS cloner

RUN apt-get update && apt-get install -y git

# Copy local repository into Docker build context
COPY . /tmp/numerics-playground-source

# Clone shallowly from local repository (pretending local is a remote)
RUN git clone --depth 1 file:///tmp/numerics-playground-source /numerics-playground && \
    cd /numerics-playground && \
    git submodule update --init --depth 1

# Stage 2: Final stage
FROM debian:trixie-20251117-slim

RUN apt-get update && apt-get install -y \
    curl wget git clang tar cmake make build-essential \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    libmpfr-dev libmpfr6 libmpfrc++-dev libgmp-dev \
    flex bison autoconf autotools-dev automake libtool \
    tmux mosh vim time \
    ocaml libnum-ocaml-dev libboost-dev

## Install Python
ENV PYVERSION=3.9.25
RUN curl -L https://www.python.org/ftp/python/${PYVERSION}/Python-${PYVERSION}.tgz -o Python-${PYVERSION}.tgz && tar -xvf Python-${PYVERSION}.tgz && cd Python-${PYVERSION} && ./configure && make && make install

# Copy ONLY the cloned repository from the cloner stage
COPY --from=cloner /numerics-playground /numerics-playground

WORKDIR /numerics-playground

############################
###### satire deps    ######
############################

###### python packages ######
RUN pip3 install deps/sly
# symengine install
RUN pip3 install cython
RUN cd deps/symengine && mkdir build && cd build && cmake .. && make && make install 
RUN cd deps/symengine.py && pip3 install .
RUN pip3 install sympy==1.14.0
RUN pip3 install deps/bigfloat
RUN pip3 install numpy

###### gelpia ######
# rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup default nightly-2024-11-30

# crlibm
RUN cd deps/crlibm && ./prepare --enable-mpfr && ./configure CXXFLAGS="-std=c++14" --enable-sse2 CFLAGS="-fPIC" LDFLAGS="-fPIC" && \
    make && make install
# gaol
RUN cd deps/GAOL && git apply ../gelpia/documents/gaol-4.2.0.patch && \
    ./configure CXXFLAGS="-std=c++14" --with-mathlib=crlibm \
    --enable-simd --enable-preserve-rounding=yes \
    --disable-debug --enable-optimize --disable-verbose-mode && \
    make && make install
# gdtoa (got decoupled from gaol so need to build separately now)
RUN cd deps/gdtoa && bash autogen.sh && ./configure && make && make install
# finally, we build gelpia
RUN cd deps/gelpia && RUSTFLAGS="-L /usr/local/lib" make
ENV PATH="/numerics-playground/deps/gelpia/bin:${PATH}"

# libgr
RUN apt install -y libxt6 libxrender1 libxext6 libqt6widgets6
RUN cd && curl -L https://gr-framework.org/downloads/gr-latest-Debian-x86_64.tar.gz -o gr.tar.gz && tar -xvf gr.tar.gz
RUN echo 'export LD_LIBRARY_PATH=/usr/local/lib:/numerics-playground/deps/gelpia/target/release/deps:/root/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib:${LD_LIBRARY}' >> /root/.bashrc

###### gappa ######
RUN cd deps/gappa && ./autogen.sh && ./configure && ./remake
ENV PATH="/numerics-playground/deps/gappa/src:${PATH}"

###### fptaylor ######
RUN cd deps/FPTaylor && make all
ENV PATH="/numerics-playground/deps/FPTaylor:${PATH}"
ENV FPTAYLOR_BASE="/numerics-playground/deps/FPTaylor"

###### negfuzz ######
RUN cd fuzzrs && cargo build --release

###### benchmark tools ######
RUN cargo install --locked hyperfine@1.19.0