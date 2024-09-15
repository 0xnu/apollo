## Apollo

Apollo provides methods for loading, manipulating, and saving images, including resizing, grayscale conversion, thresholding, and basic feature extraction.

### Features

- Image loading from file path
- Image resizing with nearest-neighbor interpolation
- RGB to grayscale conversion
- Binary thresholding for grayscale images
- Simple feature extraction (edge detection)
- Image saving to file

### Requirements

- [Zig](https://en.wikipedia.org/wiki/Zig_(programming_language)) 0.11.0 or later

### How to Use

To build the project, execute:

```sh
## BUILD ##
zig build

## EXAMPLE ##
zig build run

## TEST ##
zig build test

## TFLITE ##
brew install tensorflow
zig build run-mnist-convert
```

> mnist_model.keras size is 2.7 MB and mnist_model.tflite size is 12 Bytes.

The resulting binary will be located in `zig-out/`.

### License

This project is licensed under the [BSD 3-Clause License](LICENSE) - see the file for details.

### Copyright

(c) 2024 [Finbarrs Oketunji](https://finbarrs.eu). All Rights Reserved.
