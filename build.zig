const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{ .default_target = .{
        .abi = .eabi,
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m0plus },
        .os_tag = .freestanding,
    } });

    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .Debug });

    const lib = b.addStaticLibrary(.{
        .name = "zig-function-use",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);

    // Read .env file
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var env_map = readEnvFile(allocator) catch |err| {
        std.debug.print("Error reading .env file: {}\n", .{err});
        return;
    };

    const pico_sdk_path = env_map.get("PICO_SDK_PATH") orelse {
        std.debug.print("Error: PICO_SDK_PATH not found in .env file\n", .{});
        return;
    };

    // CMake
    var cmake_args = std.ArrayList([]const u8).init(allocator);
    defer cmake_args.deinit();

    cmake_args.appendSlice(&[_][]const u8{
        "cmake",
        "-B",
        "./cmake-build-debug",
        "-DCMAKE_BUILD_TYPE=Debug",
    }) catch unreachable;

    const sdk_path_arg = std.fmt.allocPrint(allocator, "-DPICO_SDK_PATH={s}", .{pico_sdk_path}) catch unreachable;
    cmake_args.append(sdk_path_arg) catch unreachable;

    const cmake_generate = b.addSystemCommand(cmake_args.items);
    cmake_generate.setName("cmake : generate project");

    const cmake_build = b.addSystemCommand(&.{ "cmake", "--build", "./cmake-build-debug" });
    cmake_build.setName("cmake : build project");

    b.getInstallStep().dependOn(&cmake_build.step);

    cmake_build.step.dependOn(&cmake_generate.step);

    // Unit testing
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

/// Read variables stored in an .env file.
fn readEnvFile(allocator: std.mem.Allocator) !std.StringHashMap([]const u8) {
    var env_map = std.StringHashMap([]const u8).init(allocator);

    const cwd = std.fs.cwd();
    const file = try cwd.openFile(".env", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0 or line[0] == '#') continue;

        if (std.mem.indexOf(u8, line, "=")) |index| {
            const key = try allocator.dupe(u8, line[0..index]);
            const value = try allocator.dupe(u8, line[index + 1 ..]);
            try env_map.put(key, value);
        } else {
            std.debug.print("Invalid line format: '{s}'\n", .{line});
        }
    }

    return env_map;
}
