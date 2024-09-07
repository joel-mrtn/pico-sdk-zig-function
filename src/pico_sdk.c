#include <stdint.h>
#include "hardware/gpio.h"

void __wrap_gpio_set_dir(uint32_t gpio, bool out) {
    gpio_set_dir(gpio, out);
}

bool __wrap_gpio_get(uint32_t gpio) {
    return gpio_get(gpio);
}