from PIL import Image
import sys
import os

TILE_W = 8
TILE_H = 8

def error(msg):
    print(f"ERROR: {msg}")
    sys.exit(1)

if len(sys.argv) != 3:
    print("Use:")
    print("  png2fontbin.py font.png font.bin")
    sys.exit(1)

png_path = sys.argv[1]
bin_path = sys.argv[2]

if not os.path.isfile(png_path):
    error("No se encuentra el PNG. - PNG not found.")

img = Image.open(png_path).convert("RGB")
w, h = img.size

if w % TILE_W != 0 or h % TILE_H != 0:
    error("El tamaño del PNG no es múltiplo de 8. - The PNG size is not a multiple of 8.")

pixels = img.load()

# -------------------------------------------------
# Detectar color de fondo (pixel 0,0)
# -------------------------------------------------
bg_color = pixels[0, 0]

chars_x = w // TILE_W
chars_y = h // TILE_H
total_chars = chars_x * chars_y
bin_size = total_chars * TILE_H

print(f"Dimensions PNG : {w}x{h}")
print(f"Chars          : {total_chars}")
print(f"BIN size       : {bin_size} bytes")

# -------------------------------------------------
# Conversión
# -------------------------------------------------
with open(bin_path, "wb") as f:
    for cy in range(chars_y):
        for cx in range(chars_x):
            x0 = cx * TILE_W
            y0 = cy * TILE_H

            for row in range(TILE_H):
                byte = 0
                for col in range(TILE_W):
                    px = pixels[x0 + col, y0 + row]
                    if px != bg_color:
                        byte |= (1 << (7 - col))
                f.write(bytes([byte]))

print("Conversión finalizada correctamente. - Conversion completed successfully.")
