const std = @import("std");
const apollo = @import("apollo");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var processor = apollo.ImageProcessor.init(allocator);

    // Path to the image file
    var image = try processor.loadImage("examples/apollo.png");
    defer image.deinit();

    var resized = try processor.resizeImage(&image, 224, 224);
    defer resized.deinit();

    var grayscale = try processor.convertToGrayscale(&resized);
    defer grayscale.deinit();

    // Skipping the binary thresholding for now
    // var binary = try processor.applyThreshold(&grayscale, 128);
    // defer binary.deinit();

    const features = try processor.extractFeatures(&resized);
    defer allocator.free(features);

    // Save the grayscale image instead of the binary image
    try processor.saveImage(&grayscale, "examples/apollo_processed.png");

    std.debug.print("Image processing completed. Features extracted: {d}\n", .{features.len});
}
