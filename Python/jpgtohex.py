import argparse
from PIL import Image


def jpg_to_hex(input_path, output_path, width, height):
    img = Image.open(input_path).convert("RGB")
    if img.size != (width, height):
        img = img.resize((width, height), Image.BILINEAR)

    with open(output_path, "w", encoding="utf-8") as f:
        for y in range(height):
            for x in range(width):
                r, g, b = img.getpixel((x, y))
                f.write(f"{r:02X}{g:02X}{b:02X}\n")


def main():
    parser = argparse.ArgumentParser(description="Convert JPG/PNG to RGB24 hex lines")
    parser.add_argument("--input", required=True, help="Input image path (JPG/PNG)")
    parser.add_argument("--output", required=True, help="Output hex file path")
    parser.add_argument("--width", type=int, default=1024, help="Image width")
    parser.add_argument("--height", type=int, default=768, help="Image height")
    args = parser.parse_args()

    jpg_to_hex(args.input, args.output, args.width, args.height)


if __name__ == "__main__":
    main()
