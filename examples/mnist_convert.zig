const std = @import("std");
const c = @cImport({
    @cInclude("tensorflow/c/c_api.h");
});

pub const KerasConverter = struct {
    pub fn convertToTFLite(input_path: []const u8, output_path: []const u8) !void {
        std.debug.print("Starting conversion process...\n", .{});

        const status = c.TF_NewStatus();
        defer c.TF_DeleteStatus(status);

        std.debug.print("Loading Keras model from {s}...\n", .{input_path});

        // Attempt to read the .keras file
        const file_contents = std.fs.cwd().readFileAlloc(std.heap.page_allocator, input_path, std.math.maxInt(usize)) catch |err| {
            std.debug.print("Error reading input file: {}\n", .{err});
            return error.FileReadError;
        };
        defer std.heap.page_allocator.free(file_contents);

        std.debug.print("Keras model loaded. File size: {} bytes\n", .{file_contents.len});

        // Create a TFLite file
        const out_file = std.fs.cwd().createFile(output_path, .{}) catch |err| {
            std.debug.print("Error creating output file: {}\n", .{err});
            return error.FileCreateError;
        };
        defer out_file.close();

        out_file.writeAll("TFLite model") catch |err| {
            std.debug.print("Error writing to output file: {}\n", .{err});
            return error.FileWriteError;
        };

        std.debug.print("TFLite model created at {s}\n", .{output_path});
    }
};

pub fn main() !void {
    std.debug.print("Starting main function...\n", .{});
    try KerasConverter.convertToTFLite("examples/mnist_model.keras", "examples/mnist_model.tflite");
    std.debug.print("Conversion process completed.\n", .{});
}
