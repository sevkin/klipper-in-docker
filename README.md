# run klipper and moonraker inside docker containers

## build and flash mcu firmware

```sh
docker compose --profile mcu build
```

### for stm32
```sh
docker run --rm -it --device /dev/ttyUSB0 klipper-in-docker_klipper-mcu
```

inside container

```sh
apk add gcc-arm-none-eabi newlib-arm-none-eabi stm32flash
make menuconfig
make
stm32flash -w out/klipper.bin -v /dev/ttyUSB0
exit
```

### for avr
[lookup attached USBasp](https://github.com/dotmpe/docker-arduino/wiki/How-To-flash-bootloader) and passtrough it to docker
```sh
docker run --rm -it --device /dev/bus/usb/<BBB>/<DDD> klipper-in-docker_klipper-mcu
```

inside container

```sh
apk add gcc-avr avr-libc avrdude
make menuconfig
make
avrdude -cusbasp -p<MCU> -e -U flash:w:out/klipper.elf.hex:i
exit
```

## run klipper & moonraker (listen at localhost:7125)

- copy `docker-compose.override.sample.yaml` to `docker-compose.override.yaml`
- copy `config.sample` to `config`
- run `docker compose --profile klipper up --build`

- use https://my.mainsail.xyz as frontend

and now you ready to use https://github.com/mkuf/prind instead
