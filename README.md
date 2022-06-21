# run klipper and moonraker inside docker containers

- copy `docker-compose.override.sample.yaml` to `docker-compose.override.yaml`
- copy `config.sample` to `config`
- run `docker compose --profile mcu build` to compile firmware
- run `docker compose --profile klipper up --build` to print
- https://my.mainsail.xyz as frontend

and now you ready to use https://github.com/mkuf/prind instead
