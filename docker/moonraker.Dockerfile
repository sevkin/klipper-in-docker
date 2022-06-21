FROM ubuntu:22.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt -y install \
    git \
    python3-dev \
    python3-venv \
    libcurl4-openssl-dev \
    libssl-dev \
    gcc

WORKDIR /opt

ARG REPO=https://github.com/Arksine/moonraker
ARG VERSION=master
RUN git clone ${REPO} moonraker \
    && cd moonraker \
    && git checkout ${VERSION} \
    && rm -rf .git

RUN python3 -m venv venv \
    && venv/bin/pip install -r moonraker/scripts/moonraker-requirements.txt \
    && venv/bin/python -m compileall moonraker/moonraker

FROM ubuntu:22.04 AS run

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt -y upgrade \
    && apt -y install \
    python3 \
    iproute2 \
    libsodium23 \
    && apt clean
# TODO some unwanted? libs from printd sources
# libopenjp2-7 \
# python3-libgpiod \
# curl \
# libcurl4 \
# libssl1.1 \
# liblmdb0 \
# libsodium23 \
# libjpeg62-turbo \
# libtiff5 \
# libxcb1 \
# zlib1g \

COPY --from=build /opt /opt

WORKDIR /home/klipper

RUN useradd -d /home/klipper -m -l -N -g users -u 1000 -s /bin/false moonraker \
    && mkdir run cfg gcode db log \
    && chown -R moonraker:dialout /home/klipper

USER moonraker
EXPOSE 7125
VOLUME ["/home/klipper/run", "/home/klipper/cfg", "/home/klipper/gcode", "/home/klipper/db"]
ENTRYPOINT ["/opt/venv/bin/python", "/opt/moonraker/moonraker/moonraker.py"]
CMD ["-c", "cfg/moonraker.cfg"]
