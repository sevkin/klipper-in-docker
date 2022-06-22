FROM alpine:3.16 AS build
RUN apk add --update git gcc python3-dev py3-cffi libffi-dev musl-dev
WORKDIR /opt
ARG REPO=https://github.com/Klipper3d/klipper
ARG VERSION=master
RUN git clone ${REPO} klipper \
    && cd klipper \
    && git checkout ${VERSION} \
    && rm -rf .git
RUN python3 -m venv venv \
    && venv/bin/pip3 install -r klipper/scripts/klippy-requirements.txt \
    && venv/bin/python3 -m compileall klipper/klippy \
    && venv/bin/python3 klipper/klippy/chelper/__init__.py


FROM alpine:3.16 AS mcu
RUN apk add --update make python3 gcc-arm-none-eabi newlib-arm-none-eabi stm32flash
WORKDIR /opt/klipper
COPY --from=build /opt /opt
CMD [ "/bin/ash" ]


FROM alpine:3.16 as run
WORKDIR /home/klipper
RUN apk add --update python3 py3-cffi libffi \
    && rm /var/cache/apk/* \
    && adduser -u 1000 -G users -s /bin/false -D klipper \
    && addgroup klipper dialout \
    && mkdir run cfg gcode log
COPY --from=build /opt/venv /opt/venv
COPY --from=build /opt/klipper/klippy /opt/klipper/klippy
USER klipper
VOLUME ["/home/klipper/run", "/home/klipper/cfg", "/home/klipper/gcode"]
ENTRYPOINT ["/opt/venv/bin/python3", "/opt/klipper/klippy/klippy.py"]
CMD ["-I", "run/klipper.tty", "-a", "run/klipper.sock", "cfg/printer.cfg"]
