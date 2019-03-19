Dockerfile and scripts to build MicroPython for ESP32/ESP8266 
======================

Full README to come some day...

For now, just run:

- `./setup.sh`
- `./build.sh <esp32|esp8266>`

The firmware will be placed in the current directory with the filename `firmware-<esp32|esp8266>.bin`.

To add Python source directories to be baked (frozen) into the firmware, edit `_run.sh`. 
For example, with the following folder structure:

```
├─ micropython-esp-firmware-builder
   ├─ _run.sh
   ├─ Dockerfile
   ├─ ...
├─ micropython-app
   ├─ mylib
      ├─ __init__.py
      ├─ ...
   ├─ boot.py
   ├─ main.py
   ├─ ...
```

...the `-v` argument in `run()` would be: `-v $(pwd)../micropython-app/mylib:/build/micropython/ports/$arch/modules/mylib`. So, the full `run()` function in `_run.sh` would be:

```
function run () {
  arch=$1
  shift
  echo ARCH: $arch
  echo ARGS: $*

  docker run \
    --rm \
    -it \
    -v $(pwd)/../micropython-app/mylib:/build/micropython/ports/$arch/modules/mylib \
    --user root \
    --workdir /build/micropython/ports/$arch \
    micropython  \
    $*
}
```

Note: in some projects, I have a lot of code being frozen, so when building for the ESP8266, the stock segment configuration does not allocate enough ROM to store it all. To get around this, I have a local copy of `esp8266.ld` with the ROM segment size changed (`irom0_0_seg` originally had a `len` of `0x8f000`):

```
/* GNU linker script for ESP8266 */

MEMORY
{
    dport0_0_seg : org = 0x3ff00000, len = 0x10
    dram0_0_seg :  org = 0x3ffe8000, len = 0x14000
    iram1_0_seg :  org = 0x40100000, len = 0x8000
    irom0_0_seg :  org = 0x40209000, len = 0xa7000 // <- edited length value
}

/* define common sections and symbols */
INCLUDE esp8266_common.ld

```

...this is then added to the container with another `-v` in the `run()` function in `_run.sh`:

```
  docker run \
    --rm \
    -it \
    -v $(pwd)/../micropython-app/mylib:/build/micropython/ports/$arch/modules/mylib \
    -v $(pwd)/../esp8266.ld:/build/micropython/ports/esp8266/esp8266.ld \
    --user root \
    --workdir /build/micropython/ports/$arch \
    micropython  \
    $*
````
