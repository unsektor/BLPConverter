FROM debian:trixie-slim AS blp-converter-builder-debian
RUN <<EOF
set -eux
apt-get update
apt-get install -y --no-install-recommends --no-install-suggests build-essential zlib1g-dev libbz2-dev cmake
rm -rf /var/lib/apt/lists/*
EOF

COPY . /src

RUN <<EOF
set -eux
mkdir /build
cd /build
cmake \
  -DCMAKE_CXX_FLAGS="-Wno-incompatible-pointer-types" \
  -DCMAKE_C_FLAGS="-Wno-incompatible-pointer-types" \
  -DCMAKE_CXX_FLAGS="-Wno-narrowing" \
  /src
cmake --build .
EOF

WORKDIR /build

ENTRYPOINT ["/bin/bash"]

ENV PATH=/build/bin:$PATH

FROM debian:trixie-slim AS blp-converter-debian

COPY --from=blp-converter-builder-debian /build/bin/BLPConverter /usr/local/bin

WORKDIR /opt/data

ENTRYPOINT ["/usr/local/bin/BLPConverter"]
