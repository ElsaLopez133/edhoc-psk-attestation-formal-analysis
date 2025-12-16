FROM debian:12-slim

LABEL version="1.0" \
      description="EDHOC-PSK analysis container with ProVerif + Tamarin" \
      org.opencontainers.image.authors="Anonymous"

# ------------------------------------------------------
# Install system dependencies
# ------------------------------------------------------
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      m4 ocaml ocamlbuild ocaml-findlib graphviz libgraphviz-dev \
      pkg-config curl build-essential git camlp4-extra locales \
      libgmp-dev zlib1g-dev libgtk2.0-dev liblablgtk2-ocaml-dev unzip && \
    # Generate UTF-8 locale
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set environment for UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ------------------------------------------------------
# Install ProVerif 
# ------------------------------------------------------
# Install ProVerif from source (CLI only)
RUN cd /opt && \
    curl -fsSL -O https://proverif.inria.fr/proverif2.05.tar.gz && \
    tar -xzf proverif2.05.tar.gz && \
    cd proverif2.05 && \
    ./build  && \
    ln -s "$(pwd)/proverif" /usr/local/bin/proverif

# ------------------------------------------------------
# Install Tamarin Prover (prebuilt release)
# ------------------------------------------------------
RUN cd /opt && \
    curl -LO https://github.com/tamarin-prover/tamarin-prover/releases/download/1.10.0/tamarin-prover-1.10.0-linux64-ubuntu.tar.gz && \
    tar -xzf tamarin-prover-1.10.0-linux64-ubuntu.tar.gz && \
    chmod +x tamarin-prover && \
    mv tamarin-prover /usr/local/bin/tamarin-prover


RUN cd /opt && \
    curl -LO https://github.com/maude-lang/Maude/releases/download/Maude3.3.1/Maude-linux.zip && \
    unzip Maude-linux.zip && \
    mv Linux64 maude && \
    chmod +x /opt/maude/maude.linux64 && \
    mv /opt/maude/maude.linux64 /opt/maude/maude && \
    ln -s /opt/maude/maude /usr/local/bin/maude

# ------------------------------------------------------
# PATH for good measure (not strictly needed due to symlinks)
# ------------------------------------------------------
ENV PATH="/opt/proverif:/opt/tamarin-prover:/opt/maude:$PATH"


# ------------------------------------------------------
# Project working directory
# ------------------------------------------------------
RUN mkdir -p /opt/lake-edhoc-psk
WORKDIR /opt/lake-edhoc-psk

# Copy repository into container
COPY . .

# ------------------------------------------------------
# Entrypoint
# ------------------------------------------------------
# COPY Docker/res/entrypoint.sh /usr/local/bin/
# RUN chmod 755 /usr/local/bin/entrypoint.sh
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# EXPOSE 3001
