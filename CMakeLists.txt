cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)

project(zig_function_use C CXX ASM)
set(CMAKE_C_STANDARD 23)
set(CMAKE_CXX_STANDARD 23)
pico_sdk_init()

add_compile_options(-Wall)

add_executable(zig_function_use zig_function_use.c src/pico_sdk.c)

add_library(zig_library STATIC IMPORTED)
set_property(TARGET zig_library PROPERTY IMPORTED_LOCATION ../zig-out/lib/libzig-function-use.a)

target_link_libraries(zig_function_use
    zig_library
    pico_stdlib
    -Wl,--wrap=gpio_set_dir
    -Wl,--wrap=gpio_get
)

pico_enable_stdio_usb(zig_function_use 1)

pico_add_extra_outputs(zig_function_use)