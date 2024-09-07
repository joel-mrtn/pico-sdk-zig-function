# Zig functions with Pico SDK

This small project is based on [this article](https://zig.news/anders/call-c-from-zig-on-the-pico-47p) by Anders
Holmberg, in which he describes how to call C functions defined in
the [Pico SDK](https://github.com/raspberrypi/pico-sdk) from Zig. This program only reads the signal input from GPIO 15
on a Raspberry Pi Pico (W) and prints out if GPIO 15 is set or not. I made a personal addition to the `build.zig` file
to get the Pico SDK path environment variable from an `.env` file.

```dotenv
# .env
PICO_SDK_PATH=/path/to/your/pico-sdk
```

## Breadboard circuit

The GPIO 15 pin can be connected an removed to see the output difference in the program.

![Breadboard](/assets/pin_active_bb.png)