# VGA Controller (Simulation Only)

This project simulates a VGA controller pipeline for XGA 1024x768 @ 60Hz. It reads a source image (HEX), drives timing, and reconstructs the frame to a TXT/PNG output.

## Requirements
- **Icarus Verilog** (iverilog + vvp)
- **Python 3**
- **Pillow** (Python image library)

Install Pillow:
```powershell
pip install pillow
```

## Quick Run (Full Flow)
From the repository root:

1. Convert image to HEX:
```powershell
python Python\jpgtohex.py --input path\to\image.jpg --output Code\SourceImage.hex --width 1024 --height 768
```

2. Run the top-level simulation:
```powershell
iverilog -g2012 -o Results\tb_top.exe Code\vga_timing.v Code\mem_interface.v Code\top_module.v Code\tb_top_module.v
vvp Results\tb_top.exe
```
Output: `Results\ReconstructedImage.txt`

3. Convert TXT to PNG:
```powershell
python Python\txttopng.py --input Results\ReconstructedImage.txt --output Results\ReconstructedImage.png --width 1024 --height 768
```

## Timing-Only Test
```powershell
iverilog -g2012 -o Results\tb_timing.exe Code\vga_timing.v Code\tb_vga_timing.v
vvp Results\tb_timing.exe
```

## Notes
- Default image HEX file: `Code\SourceImage.hex`
- If you run without updating HEX, the output frame will be black.
