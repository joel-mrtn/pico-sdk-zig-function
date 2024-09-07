extern fn stdio_init_all() void;

extern fn printf(format: [*:0]const u8, ...) c_int;

extern fn sleep_ms(ms: u32) void;

extern fn gpio_init(gpio: u32) void;
extern fn gpio_set_dir(gpio: u32, out: bool) void;
extern fn gpio_get(gpio: u32) bool;

export fn zig_main() void {
    stdio_init_all();

    const pin: u32 = 15;

    gpio_init(pin);
    gpio_set_dir(pin, false);

    while (true) {
        const value = gpio_get(pin);
        if (value) {
            _ = printf("GPIO %d SET\n", pin);
        } else {
            _ = printf("GPIO %d NOT SET\n", pin);
        }
        sleep_ms(1000);
    }
}
