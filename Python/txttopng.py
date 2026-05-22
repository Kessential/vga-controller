import argparse
from PIL import Image


def txt_to_png(input_path, output_path, width, height):
    with open(input_path, "r", encoding="utf-8") as f:
        lines = [line.strip() for line in f if line.strip()]

    expected = width * height
    if len(lines) < expected:
        raise ValueError(f"Not enough pixels: got {len(lines)}, expected {expected}")

    img = Image.new("RGB", (width, height))
    idx = 0
    for y in range(height):
        for x in range(width):
            value = int(lines[idx], 16)
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
            img.putpixel((x, y), (r, g, b))
            idx += 1

    img.save(output_path)


def main():
    parser = argparse.ArgumentParser(description="Convert RGB24 hex lines to PNG")
    parser.add_argument("--input", required=True, help="Input txt path")
    parser.add_argument("--output", required=True, help="Output png path")
    parser.add_argument("--width", type=int, default=1024, help="Image width")
    parser.add_argument("--height", type=int, default=768, help="Image height")
    args = parser.parse_args()

    txt_to_png(args.input, args.output, args.width, args.height)


if __name__ == "__main__":
    main()
