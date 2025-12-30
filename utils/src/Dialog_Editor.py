import os
import json
import tkinter as tk
from tkinter import filedialog, messagebox
from tkinter import ttk
import tkinter.font as tkfont

CONFIG_FILE = "config_ascii_editor.txt"
APP_TITLE = "Dialog Editor Ver 1.0 MS_Engine"

DEFAULTS = {
    "line_width": 30,
    "max_chars": 512,
    "newline_symbol": "%",   # solo para saltos MANUALES (Enter)
    "eot_symbol": "*",
    "enforce_ascii": True,
}

def load_config():
    cfg = DEFAULTS.copy()
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                cfg.update(json.load(f))
        except Exception:
            pass

    cfg["line_width"] = max(5, int(cfg.get("line_width", 30)))
    cfg["max_chars"] = max(1, int(cfg.get("max_chars", 512)))

    nl = str(cfg.get("newline_symbol", "%"))[:1] or "%"
    eot = str(cfg.get("eot_symbol", "*"))[:1] or "*"
    cfg["newline_symbol"] = nl
    cfg["eot_symbol"] = eot

    cfg["enforce_ascii"] = bool(cfg.get("enforce_ascii", True))
    return cfg

def save_config(cfg):
    try:
        with open(CONFIG_FILE, "w", encoding="utf-8") as f:
            json.dump(cfg, f, ensure_ascii=False, indent=2)
    except Exception:
        pass

def is_ascii(s: str) -> bool:
    try:
        s.encode("ascii")
        return True
    except UnicodeEncodeError:
        return False

def from_game_format(file_text: str, newline_symbol: str, eot_symbol: str) -> str:
    if file_text.endswith(eot_symbol):
        file_text = file_text[:-1]
    return file_text.replace(newline_symbol, "\n")

def apply_eot_if_needed(game_text: str, max_chars: int, eot_symbol: str) -> str:
    if len(game_text) > max_chars:
        raise ValueError(f"El texto exportado ocupa {len(game_text)} caracteres y el máximo es {max_chars}.")
    if len(game_text) == max_chars:
        return game_text
    if len(game_text) + 1 > max_chars:
        raise ValueError("No hay espacio para añadir el símbolo de fin de texto dentro del máximo configurado.")
    return game_text + eot_symbol

class ConfigDialog(tk.Toplevel):
    def __init__(self, parent, cfg):
        super().__init__(parent)
        self.title("Configuración")
        self.resizable(False, False)
        self.result = None

        frm = ttk.Frame(self, padding=12)
        frm.pack(fill="both", expand=True)

        self.var_width = tk.IntVar(value=cfg["line_width"])
        self.var_max = tk.IntVar(value=cfg["max_chars"])
        self.var_nl = tk.StringVar(value=cfg["newline_symbol"])
        self.var_eot = tk.StringVar(value=cfg["eot_symbol"])
        self.var_ascii = tk.BooleanVar(value=cfg["enforce_ascii"])

        row = 0
        ttk.Label(frm, text="Ancho de línea (caracteres):").grid(row=row, column=0, sticky="w", pady=4)
        ttk.Spinbox(frm, from_=5, to=200, textvariable=self.var_width, width=8).grid(row=row, column=1, sticky="w")

        row += 1
        ttk.Label(frm, text="Máx. caracteres del TXT:").grid(row=row, column=0, sticky="w", pady=4)
        ttk.Spinbox(frm, from_=1, to=65535, textvariable=self.var_max, width=8).grid(row=row, column=1, sticky="w")

        row += 1
        ttk.Label(frm, text="Símbolo salto de línea en fichero:").grid(row=row, column=0, sticky="w", pady=4)
        ttk.Entry(frm, textvariable=self.var_nl, width=8).grid(row=row, column=1, sticky="w")

        row += 1
        ttk.Label(frm, text="Símbolo fin de texto:").grid(row=row, column=0, sticky="w", pady=4)
        ttk.Entry(frm, textvariable=self.var_eot, width=8).grid(row=row, column=1, sticky="w")

        row += 1
        ttk.Checkbutton(frm, text="Forzar ASCII (elimina caracteres no ASCII)", variable=self.var_ascii)\
            .grid(row=row, column=0, columnspan=2, sticky="w", pady=(6, 0))

        btns = ttk.Frame(frm)
        btns.grid(row=row+1, column=0, columnspan=2, sticky="e", pady=(12, 0))
        ttk.Button(btns, text="Cancelar", command=self.on_cancel).pack(side="right", padx=6)
        ttk.Button(btns, text="Guardar", command=self.on_ok).pack(side="right")

        self.bind("<Escape>", lambda e: self.on_cancel())
        self.protocol("WM_DELETE_WINDOW", self.on_cancel)
        self.grab_set()
        self.transient(parent)

    def on_ok(self):
        nl = (self.var_nl.get() or "%")[:1]
        eot = (self.var_eot.get() or "*")[:1]
        if nl == eot:
            messagebox.showerror("Error", "El símbolo de salto de línea y el símbolo de fin de texto no pueden ser iguales.")
            return
        self.result = {
            "line_width": int(self.var_width.get()),
            "max_chars": int(self.var_max.get()),
            "newline_symbol": nl,
            "eot_symbol": eot,
            "enforce_ascii": bool(self.var_ascii.get()),
        }
        self.destroy()

    def on_cancel(self):
        self.result = None
        self.destroy()

class AsciiDialogEditor:
    def __init__(self, root):
        self.root = root
        self.cfg = load_config()

        self.current_file = None
        self.dirty = False
        self.suspend_modified = False

        self.root.title(APP_TITLE)

        self._build_menu()
        self._build_ui()
        self._apply_fixed_width_geometry()

        self.root.protocol("WM_DELETE_WINDOW", self.on_exit)

    def _build_menu(self):
        menubar = tk.Menu(self.root)

        filemenu = tk.Menu(menubar, tearoff=0)
        filemenu.add_command(label="Abrir TXT...", command=self.open_txt)
        filemenu.add_command(label="Guardar", command=self.save_txt)
        filemenu.add_command(label="Guardar como...", command=self.save_as_txt)
        filemenu.add_separator()
        filemenu.add_command(label="Cerrar TXT", command=self.close_txt)
        filemenu.add_separator()
        filemenu.add_command(label="Salir", command=self.on_exit)
        menubar.add_cascade(label="Archivo", menu=filemenu)

        cfgmenu = tk.Menu(menubar, tearoff=0)
        cfgmenu.add_command(label="Configurar...", command=self.configure)
        menubar.add_cascade(label="Opciones", menu=cfgmenu)

        self.root.config(menu=menubar)

    def _build_ui(self):
        top = ttk.Frame(self.root, padding=(10, 8, 10, 6))
        top.pack(fill="x")
        self.count_var = tk.StringVar(value="")
        ttk.Label(top, textvariable=self.count_var).pack(side="right")

        editor_frame = ttk.Frame(self.root, padding=(10, 0, 10, 10))
        editor_frame.pack(fill="both", expand=True)

        self.font = tkfont.Font(family="Consolas", size=16)

        self.text = tk.Text(
            editor_frame,
            undo=True,
            wrap="char",
            font=self.font
        )

        # ✅ clave: NO dejar que se estire horizontalmente
        self.text.pack(side="left", fill="y", expand=False)

        # el frame sí puede crecer, pero el Text no cambiará de ancho
        editor_frame.columnconfigure(0, weight=0)
        editor_frame.rowconfigure(0, weight=1)

        vbar = ttk.Scrollbar(editor_frame, orient="vertical", command=self.text.yview)
        vbar.pack(side="right", fill="y")
        self.text.configure(yscrollcommand=vbar.set)

        self.text.bind("<<Modified>>", self._on_modified)
        self._update_count()

    def _apply_fixed_width_geometry(self):
        self.text.configure(width=self.cfg["line_width"])

        # Ajustar la ventana al tamaño "pedido" real (sin extra_px a ojo)
        self.root.update_idletasks()
        req_w = self.root.winfo_reqwidth()
        req_h = 400

        self.root.geometry(f"{req_w}x{req_h}")

        # Evitar redimensionado horizontal
        self.root.resizable(False, True)

    def _update_count(self):
        ui = self.text.get("1.0", "end-1c")
        game_len = len(ui.replace("\n", self.cfg["newline_symbol"]))
        self.count_var.set(f"{game_len}/{self.cfg['max_chars']}")

    def _on_modified(self, event=None):
        if self.suspend_modified:
            self.text.edit_modified(False)
            return
        self.text.edit_modified(False)
        self.dirty = True

        if self.cfg["enforce_ascii"]:
            ui = self.text.get("1.0", "end-1c")
            if not is_ascii(ui):
                cleaned = ui.encode("ascii", "ignore").decode("ascii")
                self.suspend_modified = True
                self.text.delete("1.0", "end")
                self.text.insert("1.0", cleaned)
                self.suspend_modified = False
                messagebox.showwarning("Aviso", "Se eliminaron caracteres no ASCII.")

        self._update_count()

    def maybe_save(self):
        if not self.dirty:
            return True
        res = messagebox.askyesnocancel("Guardar", "Hay cambios sin guardar. ¿Quieres guardarlos?")
        if res is None:
            return False
        if res is True:
            return self.save_txt()
        return True

    def open_txt(self):
        if not self.maybe_save():
            return
        path = filedialog.askopenfilename(
            title="Abrir TXT",
            filetypes=[("Text files", "*.txt"), ("All files", "*.*")]
        )
        if not path:
            return
        try:
            with open(path, "r", encoding="utf-8", errors="replace") as f:
                file_text = f.read()
            ui_text = from_game_format(file_text, self.cfg["newline_symbol"], self.cfg["eot_symbol"])

            self.suspend_modified = True
            self.text.delete("1.0", "end")
            self.text.insert("1.0", ui_text)
            self.text.edit_modified(False)
            self.suspend_modified = False

            self.current_file = path
            self.dirty = False
            self._update_count()
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo abrir:\n{e}")

    def close_txt(self):
        if not self.maybe_save():
            return
        self.suspend_modified = True
        self.text.delete("1.0", "end")
        self.text.edit_modified(False)
        self.suspend_modified = False
        self.current_file = None
        self.dirty = False
        self._update_count()

    def save_txt(self):
        if not self.current_file:
            return self.save_as_txt()
        try:
            self._save_to_path(self.current_file)
            self.dirty = False
            messagebox.showinfo("OK", "Guardado correctamente.")
            return True
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo guardar:\n{e}")
            return False

    def save_as_txt(self):
        path = filedialog.asksaveasfilename(
            title="Guardar como",
            defaultextension=".txt",
            filetypes=[("Text files", "*.txt"), ("All files", "*.*")]
        )
        if not path:
            return False
        try:
            self._save_to_path(path)
            self.current_file = path
            self.dirty = False
            messagebox.showinfo("OK", "Guardado correctamente.")
            return True
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo guardar:\n{e}")
            return False

    def _save_to_path(self, path):
        ui_text = self.text.get("1.0", "end-1c")

        if self.cfg["enforce_ascii"] and not is_ascii(ui_text):
            raise ValueError("El texto contiene caracteres no ASCII. Desactiva 'Forzar ASCII' si lo necesitas.")

        game_text = ui_text.replace("\n", self.cfg["newline_symbol"])
        final_text = apply_eot_if_needed(game_text, self.cfg["max_chars"], self.cfg["eot_symbol"])

        with open(path, "w", encoding="utf-8", newline="") as f:
            f.write(final_text)

        self._update_count()

    def configure(self):
        dlg = ConfigDialog(self.root, self.cfg)
        self.root.wait_window(dlg)
        if dlg.result:
            self.cfg.update(dlg.result)
            save_config(self.cfg)
            self._apply_fixed_width_geometry()
            self._update_count()

    def on_exit(self):
        if not self.maybe_save():
            return
        self.root.destroy()

if __name__ == "__main__":
    root = tk.Tk()
    app = AsciiDialogEditor(root)
    root.mainloop()
