FROM ubuntu:22.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt -y install \
    git \
    gcc \
    python3 \
    python3-greenlet \
    python3-cffi \
    python3-serial \
    python3-jinja2

WORKDIR /opt

ARG REPO=https://github.com/Klipper3d/klipper
ARG VERSION=master
RUN git clone ${REPO} klipper \
    && cd klipper \
    && git checkout ${VERSION} \
    && rm -rf .git

RUN python3 -m compileall klipper/klippy \
    && python3 klipper/klippy/chelper/__init__.py


FROM ubuntu:22.04 AS run

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt -y upgrade \
    && apt -y install \
    python3 \
    python3-greenlet \
    python3-cffi \
    python3-serial \
    python3-jinja2 \
    && apt clean

COPY --from=build /opt/klipper /opt/klipper

WORKDIR /home/klipper

RUN useradd -d /home/klipper -m -l -N -g users -G dialout -u 1000 -s /bin/false klipper \
    && mkdir run cfg gcode log \
    && chown -R klipper:dialout /home/klipper

USER klipper
VOLUME ["/home/klipper/run", "/home/klipper/cfg", "/home/klipper/gcode"]
ENTRYPOINT ["python3", "/opt/klipper/klippy/klippy.py"]
CMD ["-I", "run/klipper.tty", "-a", "run/klipper.sock", "cfg/printer.cfg"]


FROM ubuntu:22.04 AS mcu

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt -y install \
    make \
    cpp \
    binutils \
    gcc-arm-none-eabi
RUN apt -y install \
    python3-minimal \
    stm32flash

COPY --from=build /opt/klipper /opt/klipper

WORKDIR /opt/klipper

# make menuconfig
# make create-board-link
# make
