import os
import struct
import tkinter as tk
from tkinter import filedialog, simpledialog, messagebox
from PIL import Image, ImageTk

CONFIG_FILE = "config.txt"
VERSION = "1.0.0"

class TileNumberingApp:
    def __init__(self, root):
        self.root = root
        self.root.title(f"🧱 Tile Behaviour Assigment Tool - Ver.{VERSION} (Pat Morita Team)")

        # Imagen y datos
        self.image = None
        self.image_path = None
        self.tiles = []
        self.tile_numbers = []
        self.tile_size = None
        self.cols = 0
        self.rows = 0
        self.scale = 2  # Escala inicial x2
        self.tk_images = []

        # Rutas recordadas
        self.paths = {
            "last_png_path": "",
            "last_bin_save_path": "",
            "last_bin_import_path": ""
        }
        self.load_config()

        # UI
        self.create_ui()

    # ---------- CONFIG ----------
    def load_config(self):
        """Lee las rutas guardadas desde config.txt."""
        if not os.path.exists(CONFIG_FILE):
            return
        try:
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                for line in f:
                    if "=" in line:
                        key, value = line.strip().split("=", 1)
                        if key in self.paths:
                            self.paths[key] = value
        except Exception:
            pass

    def save_config(self):
        """Guarda las rutas actuales en config.txt."""
        try:
            with open(CONFIG_FILE, "w", encoding="utf-8") as f:
                for key, value in self.paths.items():
                    f.write(f"{key}={value}\n")
        except Exception as e:
            messagebox.showwarning("Aviso", f"No se pudo guardar config.txt:\n{e}")

    # ---------- UI ----------
    def create_ui(self):
        # Frame superior (zoom + reset)
        top_frame = tk.Frame(self.root)
        top_frame.pack(fill=tk.X, pady=2)

        tk.Button(top_frame, text="🔍 +", command=self.zoom_in).pack(side=tk.LEFT, padx=2)
        tk.Button(top_frame, text="🔍 –", command=self.zoom_out).pack(side=tk.LEFT, padx=2)
        tk.Button(top_frame, text="🔄 Poner todo a 0", command=self.reset_all).pack(side=tk.LEFT, padx=10)

        # Canvas
        self.canvas = tk.Canvas(self.root, bg="gray")
        self.canvas.pack(fill=tk.BOTH, expand=True)
        self.canvas.bind("<Button-1>", self.on_click)
        self.root.bind("<Control-MouseWheel>", self.on_ctrl_mousewheel)

        # Menú
        menubar = tk.Menu(self.root)
        filemenu = tk.Menu(menubar, tearoff=0)
        filemenu.add_command(label="Abrir PNG...", command=self.load_png)
        filemenu.add_command(label="Importar BIN...", command=self.import_bin)
        filemenu.add_command(label="Guardar BIN...", command=self.save_bin)
        filemenu.add_separator()
        filemenu.add_command(label="Salir", command=self.root.quit)
        menubar.add_cascade(label="Archivo", menu=filemenu)
        self.root.config(menu=menubar)

    # ---------- LÓGICA PRINCIPAL ----------
    def load_png(self):
        initial_dir = self.paths["last_png_path"] or os.getcwd()
        file_path = filedialog.askopenfilename(
            title="Selecciona la hoja de tiles PNG",
            filetypes=[("Imagen PNG", "*.png")],
            initialdir=initial_dir
        )
        if not file_path:
            return

        try:
            self.image = Image.open(file_path)
            self.image_path = file_path
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo abrir la imagen:\n{e}")
            return

        self.paths["last_png_path"] = os.path.dirname(file_path)
        self.save_config()

        # Tamaño del tile
        tile_size = simpledialog.askinteger(
            "Tamaño de tile",
            "Introduce el tamaño de tile (8 u 16):",
            minvalue=8, maxvalue=16, initialvalue=16
        )
        if tile_size not in [8, 16]:
            messagebox.showerror("Error", "El tamaño debe ser 8 o 16.")
            return

        self.tile_size = tile_size
        self.prepare_tiles()
        self.draw_canvas()
        self.auto_resize_window()
        self.load_associated_bin()

    def prepare_tiles(self):
        self.tiles.clear()
        self.tile_numbers.clear()
        self.tk_images.clear()

        img_w, img_h = self.image.size
        self.cols = img_w // self.tile_size
        self.rows = img_h // self.tile_size

        for y in range(self.rows):
            for x in range(self.cols):
                tile = self.image.crop((
                    x * self.tile_size,
                    y * self.tile_size,
                    (x + 1) * self.tile_size,
                    (y + 1) * self.tile_size
                ))
                self.tiles.append(tile)
                self.tile_numbers.append(0)  # por defecto

    def draw_canvas(self):
        self.canvas.delete("all")
        self.tk_images.clear()
        if not self.tiles:
            return

        display_size = self.tile_size * self.scale
        total_w = self.cols * display_size
        total_h = self.rows * display_size
        self.canvas.config(scrollregion=(0, 0, total_w, total_h))

        for index, tile in enumerate(self.tiles):
            x = (index % self.cols) * display_size
            y = (index // self.cols) * display_size

            display_tile = tile.resize((display_size, display_size), Image.NEAREST)
            tile_img = ImageTk.PhotoImage(display_tile)
            self.tk_images.append(tile_img)
            self.canvas.create_image(x, y, image=tile_img, anchor="nw")

            self.canvas.create_rectangle(
                x, y, x + display_size, y + display_size,
                outline="#808080"
            )

            num = str(self.tile_numbers[index])
            font_size = max(10, display_size // 2)
            offsets = [(-1,0),(1,0),(0,-1),(0,1)]
            for ox, oy in offsets:
                self.canvas.create_text(
                    x + display_size // 2 + ox,
                    y + display_size // 2 + oy,
                    text=num,
                    fill="black",
                    font=("Arial", font_size, "bold")
                )
            self.canvas.create_text(
                x + display_size // 2,
                y + display_size // 2,
                text=num,
                fill="white",
                font=("Arial", font_size, "bold")
            )

    def on_click(self, event):
        if not self.tiles:
            return
        display_size = self.tile_size * self.scale
        col = event.x // display_size
        row = event.y // display_size
        if col < 0 or row < 0 or col >= self.cols or row >= self.rows:
            return
        index = row * self.cols + col

        current = self.tile_numbers[index]
        new_val = simpledialog.askinteger(
            "Asignar número",
            f"Número actual: {current}\nIntroduce un nuevo valor (0–255):",
            minvalue=0, maxvalue=255, initialvalue=current
        )
        if new_val is not None:
            self.tile_numbers[index] = new_val
            self.draw_canvas()

    def reset_all(self):
        if not self.tiles:
            return
        if messagebox.askyesno("Confirmar", "¿Poner todos los tiles a 0?"):
            self.tile_numbers = [0] * len(self.tile_numbers)
            self.draw_canvas()

    def auto_resize_window(self):
        if not self.tiles:
            return
        display_size = self.tile_size * self.scale
        total_w = self.cols * display_size
        total_h = self.rows * display_size + 40
        screen_w = self.root.winfo_screenwidth()
        screen_h = self.root.winfo_screenheight()
        win_w = min(total_w + 20, screen_w - 50)
        win_h = min(total_h + 80, screen_h - 50)
        self.root.geometry(f"{win_w}x{win_h}")

    # ---------- ZOOM ----------
    def zoom_in(self):
        self.scale = min(self.scale + 1, 10)
        self.draw_canvas()

    def zoom_out(self):
        self.scale = max(self.scale - 1, 1)
        self.draw_canvas()

    def on_ctrl_mousewheel(self, event):
        if event.delta > 0:
            self.zoom_in()
        else:
            self.zoom_out()

    # ---------- BIN ----------
    def import_bin(self):
        if not self.tiles:
            messagebox.showerror("Error", "Carga un PNG antes de importar un BIN.")
            return
        initial_dir = self.paths["last_bin_import_path"] or os.getcwd()
        file_path = filedialog.askopenfilename(
            title="Selecciona archivo BIN",
            filetypes=[("Binario 8bit", "*.bin")],
            initialdir=initial_dir
        )
        if not file_path:
            return
        self.paths["last_bin_import_path"] = os.path.dirname(file_path)
        self.save_config()

        try:
            with open(file_path, "rb") as f:
                data = f.read()
            if len(data) != len(self.tiles):
                messagebox.showerror(
                    "Error",
                    f"El BIN tiene {len(data)} valores pero el PNG tiene {len(self.tiles)} tiles."
                )
                return
            self.tile_numbers = [int(b) for b in data]
            self.draw_canvas()
            if self.image_path:
                with open(self.image_path + ".lastbin", "w", encoding="utf-8") as assoc:
                    assoc.write(file_path)
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo importar:\n{e}")

    def load_associated_bin(self):
        if not self.image_path:
            return
        assoc_file = self.image_path + ".lastbin"
        if os.path.exists(assoc_file):
            try:
                with open(assoc_file, "r", encoding="utf-8") as f:
                    bin_path = f.read().strip()
                if os.path.isfile(bin_path):
                    if messagebox.askyesno("BIN asociado", "Se ha encontrado un BIN asociado.\n¿Cargarlo automáticamente?"):
                        with open(bin_path, "rb") as f:
                            data = f.read()
                        if len(data) == len(self.tiles):
                            self.tile_numbers = [int(b) for b in data]
                            self.draw_canvas()
            except Exception:
                pass

    def save_bin(self):
        if not self.tiles:
            messagebox.showerror("Error", "No hay tiles cargados.")
            return

        initial_dir = self.paths["last_bin_save_path"] or os.getcwd()
        file_path = filedialog.asksaveasfilename(
            title="Guardar como binario",
            defaultextension=".bin",
            initialdir=initial_dir,
            filetypes=[("Binario 8bit", "*.bin")]
        )
        if not file_path:
            return
        self.paths["last_bin_save_path"] = os.path.dirname(file_path)
        self.save_config()

        try:
            with open(file_path, "wb") as f:
                for val in self.tile_numbers:
                    f.write(struct.pack("B", int(val)))
            messagebox.showinfo("Éxito", f"Archivo binario guardado en:\n{file_path}")
            if self.image_path:
                with open(self.image_path + ".lastbin", "w", encoding="utf-8") as assoc:
                    assoc.write(file_path)
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo guardar el archivo:\n{e}")

# ---------- Lanzador ----------
if __name__ == "__main__":
    root = tk.Tk()
    app = TileNumberingApp(root)
    root.mainloop()
