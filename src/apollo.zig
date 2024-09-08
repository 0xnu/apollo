const std = @import("std");
const zigimg = @import("zigimg");

// ImageProcessor — Handles image processing operations
pub const ImageProcessor = struct {
    allocator: std.mem.Allocator,

    // init — Constructor for ImageProcessor
    pub fn init(allocator: std.mem.Allocator) ImageProcessor {
        return .{ .allocator = allocator };
    }

    // loadImage — Loads an image from a file path
    pub fn loadImage(self: *ImageProcessor, file_path: []const u8) !zigimg.Image {
        return zigimg.Image.fromFilePath(self.allocator, file_path);
    }

    // resizeImage — Resizes an image to specified dimensions using nearest-neighbor interpolation
    pub fn resizeImage(self: *ImageProcessor, image: *zigimg.Image, new_width: u32, new_height: u32) !zigimg.Image {
        var resized = try zigimg.Image.create(self.allocator, new_width, new_height, image.pixelFormat());

        const x_ratio = @as(f32, @floatFromInt(image.width)) / @as(f32, @floatFromInt(new_width));
        const y_ratio = @as(f32, @floatFromInt(image.height)) / @as(f32, @floatFromInt(new_height));

        var y: u32 = 0;
        while (y < new_height) : (y += 1) {
            var x: u32 = 0;
            while (x < new_width) : (x += 1) {
                const px = @as(u32, @intFromFloat(@floor(@as(f32, @floatFromInt(x)) * x_ratio)));
                const py = @as(u32, @intFromFloat(@floor(@as(f32, @floatFromInt(y)) * y_ratio)));
                const src_index = py * image.width + px;
                const dst_index = y * new_width + x;

                switch (image.pixelFormat()) {
                    .rgb24 => resized.pixels.rgb24[dst_index] = image.pixels.rgb24[src_index],
                    .rgba32 => resized.pixels.rgba32[dst_index] = image.pixels.rgba32[src_index],
                    .grayscale8 => resized.pixels.grayscale8[dst_index] = image.pixels.grayscale8[src_index],
                    else => return error.UnsupportedPixelFormat,
                }
            }
        }

        return resized;
    }

    // convertToGrayscale — Converts an RGB image to grayscale
    pub fn convertToGrayscale(self: *ImageProcessor, image: *zigimg.Image) !zigimg.Image {
        var grayscale = try zigimg.Image.create(self.allocator, image.width, image.height, .grayscale8);
        var it = image.iterator();
        var index: usize = 0;
        while (it.next()) |color| {
            const gray_value = @as(u8, @intFromFloat(0.299 * @as(f32, color.r) + 0.587 * @as(f32, color.g) + 0.114 * @as(f32, color.b)));
            grayscale.pixels.grayscale8[index] = .{ .value = gray_value };
            index += 1;
        }
        return grayscale;
    }

    // applyThreshold — Applies binary thresholding to a grayscale image
    pub fn applyThreshold(self: *ImageProcessor, image: *zigimg.Image, threshold: u8) !zigimg.Image {
        if (image.pixelFormat() != .grayscale8) {
            return error.InvalidPixelFormat;
        }
        var binary = try zigimg.Image.create(self.allocator, image.width, image.height, .grayscale1);
        for (image.pixels.grayscale8, 0..) |pixel, i| {
            binary.pixels.grayscale1[i] = .{ .value = if (pixel.value > threshold) 1 else 0 };
        }
        return binary;
    }

    // extractFeatures — Extracts simple features from an image like edge detection
    pub fn extractFeatures(self: *ImageProcessor, image: *zigimg.Image) ![]f32 {
        var grayscale = try self.convertToGrayscale(image);
        defer grayscale.deinit();

        const width = grayscale.width;
        const height = grayscale.height;
        var features = try self.allocator.alloc(f32, width * height);

        // Simple edge detection using Sobel operator
        for (1..height - 1) |y| {
            for (1..width - 1) |x| {
                const gx = @as(f32, @floatFromInt(grayscale.pixels.grayscale8[y * width + x + 1].value)) -
                    @as(f32, @floatFromInt(grayscale.pixels.grayscale8[y * width + x - 1].value));
                const gy = @as(f32, @floatFromInt(grayscale.pixels.grayscale8[(y + 1) * width + x].value)) -
                    @as(f32, @floatFromInt(grayscale.pixels.grayscale8[(y - 1) * width + x].value));
                features[y * width + x] = @sqrt(gx * gx + gy * gy);
            }
        }

        return features;
    }

    // saveImage — Saves an image to a file
    pub fn saveImage(self: *ImageProcessor, image: *zigimg.Image, file_path: []const u8) !void {
        _ = self;
        try image.writeToFilePath(file_path, .{ .png = .{} });
    }
};
