"""
🧱 Tile Behaviour Assignment Tool - Pat Morita Team
Versión: 1.1.5
---------------------------------------------
✅ Selector de idioma estable en Windows (reconstrucción de menús)
🌐 Traducción completa de menús, botones y diálogos
💾 Configuración persistente
"""

import os
import struct
import tkinter as tk
from tkinter import filedialog, simpledialog, messagebox
from PIL import Image, ImageTk

CONFIG_FILE = "config_tb.txt"
VERSION = "1.1.5"

# ---------------- TEXTOS MULTILINGÜES ----------------
TEXTS = {
    "es": {
        "title": f"🧱 Asignación de Comportamientos - Ver.{VERSION} (Pat Morita Team)",
        "zoom_in": "🔍 +",
        "zoom_out": "🔍 –",
        "reset": "🔄 Poner todo a 0",
        "menu_file": "Archivo",
        "open_png": "Abrir PNG...",
        "import_bin": "Importar BIN...",
        "save_bin": "Guardar BIN...",
        "exit": "Salir",
        "menu_lang": "Idioma",
        "lang_es": "Español",
        "lang_en": "English",
        "choose_png": "Selecciona la hoja de tiles PNG",
        "tile_size_title": "Tamaño de tile",
        "tile_size_prompt": "Introduce el tamaño de tile (8 u 16):",
        "tile_size_error": "El tamaño debe ser 8 o 16.",
        "assign_number_title": "Asignar número",
        "assign_number_prompt": "Número actual: {current}\nIntroduce un nuevo valor (0–255):",
        "reset_confirm": "¿Poner todos los tiles a 0?",
        "error": "Error",
        "success": "Éxito",
        "bin_saved": "Archivo binario guardado en:\n{path}",
        "load_png_error": "No se pudo abrir la imagen:\n{error}",
        "import_before_png": "Carga un PNG antes de importar un BIN.",
        "bin_tile_mismatch": "El BIN tiene {bin_count} valores pero el PNG tiene {png_count} tiles.",
        "import_error": "No se pudo importar:\n{error}",
        "bin_associated_found": "Se ha encontrado un BIN asociado.\n¿Cargarlo automáticamente?",
        "save_error": "No se pudo guardar el archivo:\n{error}",
        "no_tiles": "No hay tiles cargados.",
        "filter_png": "Imagen PNG",
        "filter_bin": "Binario 8-bit"
    },
    "en": {
        "title": f"🧱 Tile Behaviour Assignment Tool - Ver.{VERSION} (Pat Morita Team)",
        "zoom_in": "🔍 +",
        "zoom_out": "🔍 –",
        "reset": "🔄 Reset all to 0",
        "menu_file": "File",
        "open_png": "Open PNG...",
        "import_bin": "Import BIN...",
        "save_bin": "Save BIN...",
        "exit": "Exit",
        "menu_lang": "Language",
        "lang_es": "Spanish",
        "lang_en": "English",
        "choose_png": "Select the PNG tile sheet",
        "tile_size_title": "Tile size",
        "tile_size_prompt": "Enter tile size (8 or 16):",
        "tile_size_error": "Tile size must be 8 or 16.",
        "assign_number_title": "Assign number",
        "assign_number_prompt": "Current number: {current}\nEnter a new value (0–255):",
        "reset_confirm": "Reset all tiles to 0?",
        "error": "Error",
        "success": "Success",
        "bin_saved": "Binary file saved at:\n{path}",
        "load_png_error": "Could not open image:\n{error}",
        "import_before_png": "Load a PNG before importing a BIN.",
        "bin_tile_mismatch": "BIN has {bin_count} values but PNG has {png_count} tiles.",
        "import_error": "Import failed:\n{error}",
        "bin_associated_found": "An associated BIN was found.\nLoad it automatically?",
        "save_error": "Could not save file:\n{error}",
        "no_tiles": "No tiles loaded.",
        "filter_png": "PNG Image",
        "filter_bin": "8-bit Binary"
    }
}


class TileNumberingApp:
    def __init__(self, root):
        self.root = root
        self.lang = "es"

        # Datos de imagen
        self.image = None
        self.image_path = None
        self.tiles = []
        self.tile_numbers = []
        self.tile_size = None
        self.cols = 0
        self.rows = 0
        self.scale = 2
        self.tk_images = []

        # Configuración persistente
        self.paths = {
            "last_png_path": "",
            "last_bin_save_path": "",
            "last_bin_import_path": "",
            "lang": "es"
        }
        self.load_config()
        self.lang = self.paths.get("lang", "es")

        # UI
        self.create_ui()
        self.update_texts()

    # ---------- CONFIG ----------
    def load_config(self):
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
        try:
            with open(CONFIG_FILE, "w", encoding="utf-8") as f:
                for key, value in self.paths.items():
                    f.write(f"{key}={value}\n")
        except Exception as e:
            messagebox.showwarning("Aviso", f"No se pudo guardar config.txt:\n{e}")

    # ---------- UI ----------
    def create_ui(self):
        top_frame = tk.Frame(self.root)
        top_frame.pack(fill=tk.X, pady=2)

        self.zoom_in_btn = tk.Button(top_frame, command=self.zoom_in)
        self.zoom_in_btn.pack(side=tk.LEFT, padx=2)

        self.zoom_out_btn = tk.Button(top_frame, command=self.zoom_out)
        self.zoom_out_btn.pack(side=tk.LEFT, padx=2)

        self.reset_btn = tk.Button(top_frame, command=self.reset_all)
        self.reset_btn.pack(side=tk.LEFT, padx=10)

        self.canvas = tk.Canvas(self.root, bg="gray")
        self.canvas.pack(fill=tk.BOTH, expand=True)
        self.canvas.bind("<Button-1>", self.on_click)
        self.root.bind("<Control-MouseWheel>", self.on_ctrl_mousewheel)

        self.build_menus()

    def build_menus(self):
        """Reconstruye el menú superior según el idioma."""
        t = TEXTS[self.lang]
        menubar = tk.Menu(self.root)

        filemenu = tk.Menu(menubar, tearoff=0)
        filemenu.add_command(label=t["open_png"], command=self.load_png)
        filemenu.add_command(label=t["import_bin"], command=self.import_bin)
        filemenu.add_command(label=t["save_bin"], command=self.save_bin)
        filemenu.add_separator()
        filemenu.add_command(label=t["exit"], command=self.root.quit)
        menubar.add_cascade(label=t["menu_file"], menu=filemenu)

        lang_menu = tk.Menu(menubar, tearoff=0)
        lang_menu.add_command(label=t["lang_es"], command=lambda: self.set_lang("es"))
        lang_menu.add_command(label=t["lang_en"], command=lambda: self.set_lang("en"))
        menubar.add_cascade(label=t["menu_lang"], menu=lang_menu)

        self.root.config(menu=menubar)
        self.menubar = menubar

    def t(self, key):
        return TEXTS[self.lang].get(key, key)

    def update_texts(self):
        t = TEXTS[self.lang]
        self.root.title(t["title"])
        self.zoom_in_btn.config(text=t["zoom_in"])
        self.zoom_out_btn.config(text=t["zoom_out"])
        self.reset_btn.config(text=t["reset"])
        self.build_menus()

    def set_lang(self, lang):
        self.lang = lang
        self.paths["lang"] = lang
        self.save_config()
        self.update_texts()

    # ---------- LÓGICA PRINCIPAL ----------
    def load_png(self):
        initial_dir = self.paths["last_png_path"] or os.getcwd()
        file_path = filedialog.askopenfilename(
            title=self.t("choose_png"),
            filetypes=[(self.t("filter_png"), "*.png")],
            initialdir=initial_dir
        )
        if not file_path:
            return

        try:
            self.image = Image.open(file_path)
            self.image_path = file_path
        except Exception as e:
            messagebox.showerror(self.t("error"), self.t("load_png_error").format(error=e))
            return

        self.paths["last_png_path"] = os.path.dirname(file_path)
        self.save_config()

        tile_size = simpledialog.askinteger(
            self.t("tile_size_title"),
            self.t("tile_size_prompt"),
            minvalue=8, maxvalue=16, initialvalue=16
        )
        if tile_size not in [8, 16]:
            messagebox.showerror(self.t("error"), self.t("tile_size_error"))
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
                self.tile_numbers.append(0)

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

            self.canvas.create_rectangle(x, y, x+display_size, y+display_size, outline="#808080")

            num = str(self.tile_numbers[index])
            font_size = max(10, display_size // 2)
            for ox, oy in [(-1,0),(1,0),(0,-1),(0,1)]:
                self.canvas.create_text(
                    x + display_size//2 + ox,
                    y + display_size//2 + oy,
                    text=num, fill="black",
                    font=("Arial", font_size, "bold")
                )
            self.canvas.create_text(
                x + display_size//2,
                y + display_size//2,
                text=num, fill="white",
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
            self.t("assign_number_title"),
            self.t("assign_number_prompt").format(current=current),
            minvalue=0, maxvalue=255,
            initialvalue=current
        )
        if new_val is not None:
            self.tile_numbers[index] = new_val
            self.draw_canvas()

    def reset_all(self):
        if not self.tiles:
            return
        if messagebox.askyesno(self.t("reset"), self.t("reset_confirm")):
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
            messagebox.showerror(self.t("error"), self.t("import_before_png"))
            return
        initial_dir = self.paths["last_bin_import_path"] or os.getcwd()
        file_path = filedialog.askopenfilename(
            title=self.t("import_bin"),
            filetypes=[(self.t("filter_bin"), "*.bin")],
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
                    self.t("error"),
                    self.t("bin_tile_mismatch").format(bin_count=len(data), png_count=len(self.tiles))
                )
                return
            self.tile_numbers = [int(b) for b in data]
            self.draw_canvas()
            if self.image_path:
                with open(self.image_path + ".lastbin", "w", encoding="utf-8") as assoc:
                    assoc.write(file_path)
        except Exception as e:
            messagebox.showerror(self.t("error"), self.t("import_error").format(error=e))

    def load_associated_bin(self):
        if not self.image_path:
            return
        assoc_file = self.image_path + ".lastbin"
        if os.path.exists(assoc_file):
            try:
                with open(assoc_file, "r", encoding="utf-8") as f:
                    bin_path = f.read().strip()
                if os.path.isfile(bin_path):
                    if messagebox.askyesno("BIN", self.t("bin_associated_found")):
                        with open(bin_path, "rb") as f:
                            data = f.read()
                        if len(data) == len(self.tiles):
                            self.tile_numbers = [int(b) for b in data]
                            self.draw_canvas()
            except Exception:
                pass

    def save_bin(self):
        if not self.tiles:
            messagebox.showerror(self.t("error"), self.t("no_tiles"))
            return

        initial_dir = self.paths["last_bin_save_path"] or os.getcwd()
        file_path = filedialog.asksaveasfilename(
            title=self.t("save_bin"),
            defaultextension=".bin",
            initialdir=initial_dir,
            filetypes=[(self.t("filter_bin"), "*.bin")]
        )
        if not file_path:
            return
        self.paths["last_bin_save_path"] = os.path.dirname(file_path)
        self.save_config()

        try:
            with open(file_path, "wb") as f:
                for val in self.tile_numbers:
                    f.write(struct.pack("B", int(val)))
            messagebox.showinfo(self.t("success"), self.t("bin_saved").format(path=file_path))
            if self.image_path:
                with open(self.image_path + ".lastbin", "w", encoding="utf-8") as assoc:
                    assoc.write(file_path)
        except Exception as e:
            messagebox.showerror(self.t("error"), self.t("save_error").format(error=e))


# ---------- Lanzador ----------
if __name__ == "__main__":
    root = tk.Tk()
    app = TileNumberingApp(root)
    root.mainloop()
