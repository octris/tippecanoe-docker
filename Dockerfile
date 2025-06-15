###############
# 1) Builder  #
###############
FROM alpine:3.22.0 AS build

RUN apk add --no-cache build-base git zlib-dev sqlite-dev bash

ARG TIPPECANOE_REF=2.78.0

WORKDIR /src
RUN git clone --branch ${TIPPECANOE_REF} --depth 1 https://github.com/felt/tippecanoe.git
WORKDIR /src/tippecanoe

RUN make -j$(nproc)

RUN strip tippecanoe tile-join

#######################
# 2) Runtime (8 MB)   #
#######################
FROM alpine:3.22.0

RUN apk add --no-cache libstdc++ libgcc sqlite-libs zlib

COPY --from=build /src/tippecanoe/tippecanoe /usr/local/bin/
COPY --from=build /src/tippecanoe/tile-*  /usr/local/bin/
LABEL org.opencontainers.image.source="https://github.com/felt/tippecanoe"

ENTRYPOINT [ "tippecanoe" ]
