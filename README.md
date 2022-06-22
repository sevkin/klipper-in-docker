# run klipper and moonraker inside docker containers

## build and flash mcu firmware (now stm32 only)

```sh
docker compose --profile mcu build
docker run --rm -it --device /dev/ttyUSB0:/dev/ttyUSB0 klipper-in-docker_klipper-mcu
```

and inside container
```sh
make menuconfig
make
stm32flash -w out/klipper.bin -v /dev/ttyUSB0
exit
```

## run klipper & moonraker (listen at localhost:7125)

- copy `docker-compose.override.sample.yaml` to `docker-compose.override.yaml`
- copy `config.sample` to `config`
- run `docker compose --profile klipper up --build`

- use https://my.mainsail.xyz as frontend

and now you ready to use https://github.com/mkuf/prind instead
