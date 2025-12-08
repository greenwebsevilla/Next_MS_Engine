"""
Next MS Engine Updater
Versión: 1.2
- Añadido selector de idioma Español / Inglés.
- Añadido backup ZIP de la carpeta /dev/engine/ antes de actualizar.
"""

import os
import json
import shutil
import zipfile
from datetime import datetime
import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext
from urllib.parse import quote
import requests

CONFIG_FILE = "config_next_ms_engine_updater.txt"
REPO_OWNER = "greenwebsevilla"
REPO_NAME = "Next_MS_Engine"
DEFAULT_BRANCH = "main"  # cambia si tu rama es otra (por ejemplo, "master")

GITHUB_CONTENTS_API = "https://api.github.com/repos/{owner}/{repo}/contents/{path}?ref={ref}"

# ---------------- TEXTOS MULTILINGÜES ----------------
TEXTS = {
    "es": {
        "title": "Next MS Engine - Actualizador",
        "local_label": "Carpeta local del motor:",
        "choose_folder": "Elegir carpeta...",
        "branch_label": "Rama de GitHub:",
        "update_btn": "Actualizar motor",
        "exit_btn": "Salir",
        "help_btn": "Ayuda",
        "help_title": "Ayuda",
        "help_text": (
            "Esta herramienta actualiza tu copia local de Next_MS_Engine descargando:\n"
            "- 'game.bas' (raíz del repositorio)\n"
            "- todo el contenido de '/dev/engine/' (recursivo)\n\n"
            "Uso:\n"
            "1) Elige la carpeta local donde tienes el motor.\n"
            "2) (Opcional) Ajusta la rama (por defecto: 'main').\n"
            "3) Pulsa 'Actualizar motor'."
        ),
        "lang_es": "ES",
        "lang_en": "EN",
        "log_start_update": "Iniciando actualización...",
        "log_downloading_game": "Descargando 'game.bas' ...",
        "log_backup_game": "Se creó copia de seguridad: game.bas.bak",
        "log_game_ok": "OK → {path}",
        "log_backup_engine_start": "Creando copia de seguridad de '/dev/engine/' ...",
        "log_backup_engine_ok": "Copia de seguridad creada: {path}",
        "log_backup_engine_skip": "⚠ No se encontró carpeta local '/dev/engine/'. Se omite el backup.",
        "log_backup_engine_error": "⚠ Error al crear el backup de '/dev/engine/': {error}",
        "log_downloading_engine": "Descargando carpeta '/dev/engine/' ...",
        "log_warn_no_dir": "⚠ Carpeta no encontrada en repo: /{path}",
        "log_warn_no_download": "⚠ Sin URL de descarga para: {path}",
        "log_ignored": "ℹ Ignorado ({type}): {path}",
        "log_unexpected": "⚠ Respuesta inesperada en /{path}",
        "log_done": "✅ Actualización completada.",
        "status_done": "Listo.",
        "msg_ok_title": "OK",
        "msg_ok_updated": "Actualización completada correctamente.",
        "msg_error_title": "Error",
        "msg_error_choose_folder": "Primero elige la carpeta local del motor.",
        "msg_error_http": "Error HTTP {code}: {detail}",
        "msg_error_generic": "Error: {detail}",
        "path_not_selected": "(sin seleccionar)",
    },
    "en": {
        "title": "Next MS Engine - Updater",
        "local_label": "Local engine folder:",
        "choose_folder": "Choose folder...",
        "branch_label": "GitHub branch:",
        "update_btn": "Update engine",
        "exit_btn": "Exit",
        "help_btn": "Help",
        "help_title": "Help",
        "help_text": (
            "This tool updates your local copy of Next_MS_Engine by downloading:\n"
            "- 'game.bas' (repository root)\n"
            "- all contents of '/dev/engine/' (recursively)\n\n"
            "Usage:\n"
            "1) Choose the local folder where your engine is located.\n"
            "2) (Optional) Adjust the branch (default: 'main').\n"
            "3) Click 'Update engine'."
        ),
        "lang_es": "ES",
        "lang_en": "EN",
        "log_start_update": "Starting update...",
        "log_downloading_game": "Downloading 'game.bas' ...",
        "log_backup_game": "Backup created: game.bas.bak",
        "log_game_ok": "OK → {path}",
        "log_backup_engine_start": "Creating backup of '/dev/engine/' ...",
        "log_backup_engine_ok": "Backup created: {path}",
        "log_backup_engine_skip": "⚠ Local '/dev/engine/' folder not found. Skipping backup.",
        "log_backup_engine_error": "⚠ Error while creating '/dev/engine/' backup: {error}",
        "log_downloading_engine": "Downloading '/dev/engine/' folder ...",
        "log_warn_no_dir": "⚠ Folder not found in repo: /{path}",
        "log_warn_no_download": "⚠ No download URL for: {path}",
        "log_ignored": "ℹ Ignored ({type}): {path}",
        "log_unexpected": "⚠ Unexpected response for /{path}",
        "log_done": "✅ Update completed.",
        "status_done": "Done.",
        "msg_ok_title": "OK",
        "msg_ok_updated": "Update completed successfully.",
        "msg_error_title": "Error",
        "msg_error_choose_folder": "Please choose the local engine folder first.",
        "msg_error_http": "HTTP error {code}: {detail}",
        "msg_error_generic": "Error: {detail}",
        "path_not_selected": "(not selected)",
    },
}

# ---------- Utilidades de configuración ----------
def load_config():
    cfg = {"local_path": "", "branch": DEFAULT_BRANCH, "lang": "es"}
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                data = json.load(f)
                cfg.update(data)
        except Exception:
            pass
    return cfg

def save_config(cfg):
    try:
        with open(CONFIG_FILE, "w", encoding="utf-8") as f:
            json.dump(cfg, f, ensure_ascii=False, indent=2)
    except Exception:
        pass

# ---------- Lógica de GitHub ----------
def github_list_path(path, ref):
    """Devuelve lista de ítems (files/dir) para una ruta en el repo usando /contents."""
    url = GITHUB_CONTENTS_API.format(
        owner=REPO_OWNER, repo=REPO_NAME, path=quote(path), ref=quote(ref)
    )
    r = requests.get(url, timeout=30)
    r.raise_for_status()
    data = r.json()
    # Si path es archivo, data será un dict; convertimos a lista homogénea
    if isinstance(data, dict) and data.get("type") == "file":
        return [data]
    return data  # lista de dicts

def download_file(download_url, dest_path):
    """Descarga un archivo a dest_path (crea carpetas). Sobrescribe."""
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    with requests.get(download_url, stream=True, timeout=60) as r:
        r.raise_for_status()
        with open(dest_path, "wb") as f:
            for chunk in r.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)

def ensure_marker_folder(path):
    """Comprueba mínimamente que la carpeta existe."""
    return os.path.isdir(path)

# ---------- Backup de /dev/engine + game.bas ----------
def backup_before_update(local_root, log_fn, lang="es"):
    """
    Crea un ZIP de seguridad incluyendo:
    - game.bas (si existe)
    - Todo el contenido de /dev/engine/
    El ZIP se guarda en la subcarpeta "backups" dentro de la raíz del motor.
    Formato nombre: backup_DD_MM_YYYY_HH_MM.zip
    """
    t = TEXTS.get(lang, TEXTS["es"])

    dev_engine_path = os.path.join(local_root, "dev", "engine")
    game_bas_path = os.path.join(local_root, "game.bas")

    # Si no hay nada que guardar, no hacemos zip
    if not os.path.isfile(game_bas_path) and not os.path.isdir(dev_engine_path):
        log_fn(t["log_backup_engine_skip"])
        return

    try:
        log_fn(t["log_backup_engine_start"])
        now = datetime.now()
        backup_name = (
            f"backup_{now.day:02d}_{now.month:02d}_{now.year:04d}_"
            f"{now.hour:02d}_{now.minute:02d}.zip"
        )

        backups_dir = os.path.join(local_root, "backups")
        os.makedirs(backups_dir, exist_ok=True)
        backup_path = os.path.join(backups_dir, backup_name)

        with zipfile.ZipFile(backup_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
            # Incluir game.bas si existe
            if os.path.isfile(game_bas_path):
                zf.write(game_bas_path, "game.bas")

            # Incluir carpeta dev/engine si existe
            if os.path.isdir(dev_engine_path):
                for root_dir, dirs, files in os.walk(dev_engine_path):
                    for file in files:
                        full_path = os.path.join(root_dir, file)
                        arcname = os.path.relpath(full_path, local_root)
                        zf.write(full_path, arcname)

        log_fn(t["log_backup_engine_ok"].format(path=backup_path))

    except Exception as e:
        log_fn(t["log_backup_engine_error"].format(error=str(e)))


# ---------- Updater principal ----------
def perform_update(local_root, branch, log_fn, lang="es"):
    """
    - Baja game.bas a local_root/game.bas
    - Hace backup ZIP de local_root/dev/engine/
    - Recorre /dev/engine/ del repo y descarga todo a local_root/dev/engine/...
    """
    t = TEXTS.get(lang, TEXTS["es"])

    if not ensure_marker_folder(local_root):
        raise RuntimeError("Local folder does not exist.")

    # Descarga game.bas (raíz del repo)
    log_fn(t["log_downloading_game"])
    items = github_list_path("game.bas", branch)
    if not items:
        raise RuntimeError("game.bas not found in repository.")
    item = items[0]
    if item.get("type") != "file" or not item.get("download_url"):
        raise RuntimeError("game.bas is not a downloadable file.")
    dest_game = os.path.join(local_root, "game.bas")
    
    download_file(item["download_url"], dest_game)
    log_fn(t["log_game_ok"].format(path=dest_game))

    # Backup de /dev/engine/ antes de actualizar
    backup_before_update(local_root, log_fn, lang=lang)

    # Descarga contenido de /dev/engine/ (recursivo)
    log_fn(t["log_downloading_engine"])
    sync_directory_from_github(
        github_path="dev/engine",
        local_root=local_root,
        branch=branch,
        log_fn=log_fn,
        lang=lang,
    )
    log_fn(t["log_done"])

def sync_directory_from_github(github_path, local_root, branch, log_fn, lang="es"):
    """
    Sincroniza recursivamente una carpeta del repo (solo descarga/overwrite).
    github_path: p.ej. 'dev/engine'
    """
    t = TEXTS.get(lang, TEXTS["es"])
    try:
        entries = github_list_path(github_path, branch)
    except requests.HTTPError as e:
        # Si no existe la carpeta, quizá no hay engine/versión antigua
        if e.response is not None and e.response.status_code == 404:
            log_fn(t["log_warn_no_dir"].format(path=github_path))
            return
        raise

    if not isinstance(entries, list):
        log_fn(t["log_unexpected"].format(path=github_path))
        return

    for entry in entries:
        etype = entry.get("type")
        path = entry.get("path")  # ruta en repo
        if etype == "dir":
            # Recursivo
            sync_directory_from_github(path, local_root, branch, log_fn, lang=lang)
        elif etype == "file":
            download_url = entry.get("download_url")
            if not download_url:
                log_fn(t["log_warn_no_download"].format(path=path))
                continue
            # Mapeo a carpeta local
            rel = path.replace("/", os.sep)
            dest = os.path.join(local_root, rel)
            log_fn(f"  - {rel}")
            download_file(download_url, dest)
        else:
            # Ignorar symlinks/submódulos/etc.
            log_fn(t["log_ignored"].format(type=etype, path=path))

# ---------- GUI ----------
class UpdaterGUI:
    def __init__(self, root):
        self.root = root
        self.cfg = load_config()
        self.lang = self.cfg.get("lang", "es")

        self.root.title(self.t("title"))
        self.root.minsize(640, 460)

        # --- Selector de idioma (arriba derecha) ---
        lang_frame = tk.Frame(root)
        lang_frame.pack(anchor="ne", padx=10, pady=5)
        self.btn_lang_es = tk.Button(lang_frame, text=self.t("lang_es"), width=3,
                                     command=lambda: self.set_lang("es"))
        self.btn_lang_en = tk.Button(lang_frame, text=self.t("lang_en"), width=3,
                                     command=lambda: self.set_lang("en"))
        self.btn_lang_es.pack(side="left", padx=2)
        self.btn_lang_en.pack(side="left", padx=2)

        # Carpeta local
        frm_top = tk.Frame(root)
        frm_top.pack(fill="x", padx=10, pady=(0, 5))
        self.local_label = tk.Label(frm_top, text=self.t("local_label"))
        self.local_label.pack(anchor="w")
        path_row = tk.Frame(frm_top)
        path_row.pack(fill="x")
        self.path_label = tk.Label(path_row, text=self._short(self.cfg.get("local_path", "")), fg="blue")
        self.path_label.pack(side="left", padx=(0, 8))
        self.choose_btn = tk.Button(path_row, text=self.t("choose_folder"), command=self.choose_folder)
        self.choose_btn.pack(side="left")

        # Rama (branch)
        frm_branch = tk.Frame(root)
        frm_branch.pack(fill="x", padx=10, pady=(0, 10))
        self.branch_label = tk.Label(frm_branch, text=self.t("branch_label"))
        self.branch_label.pack(anchor="w")
        self.branch_var = tk.StringVar(value=self.cfg.get("branch", DEFAULT_BRANCH))
        self.branch_entry = tk.Entry(frm_branch, textvariable=self.branch_var, width=20)
        self.branch_entry.pack(anchor="w")

        # Botones
        btn_row = tk.Frame(root)
        btn_row.pack(fill="x", padx=10, pady=5)
        self.update_btn = tk.Button(btn_row, text=self.t("update_btn"), command=self.update_engine)
        self.update_btn.pack(side="left")
        self.exit_btn = tk.Button(btn_row, text=self.t("exit_btn"), command=root.quit)
        self.exit_btn.pack(side="left", padx=6)
        self.help_btn = tk.Button(btn_row, text=self.t("help_btn"), command=self.show_help)
        self.help_btn.pack(side="right")

        # Log
        self.log = scrolledtext.ScrolledText(root, height=16, state="disabled")
        self.log.pack(fill="both", expand=True, padx=10, pady=(5, 10))

        self.refresh_lang_buttons()

    # --------- Traducción ----------
    def t(self, key):
        return TEXTS.get(self.lang, TEXTS["es"]).get(key, key)

    def set_lang(self, lang):
        self.lang = lang
        self.cfg["lang"] = lang
        save_config(self.cfg)
        self.refresh_texts()

    def refresh_texts(self):
        self.root.title(self.t("title"))
        self.local_label.config(text=self.t("local_label"))
        self.choose_btn.config(text=self.t("choose_folder"))
        self.branch_label.config(text=self.t("branch_label"))
        self.update_btn.config(text=self.t("update_btn"))
        self.exit_btn.config(text=self.t("exit_btn"))
        self.help_btn.config(text=self.t("help_btn"))
        self.btn_lang_es.config(text=self.t("lang_es"))
        self.btn_lang_en.config(text=self.t("lang_en"))
        if not self.cfg.get("local_path", "").strip():
            self.path_label.config(text=self.t("path_not_selected"))
        self.refresh_lang_buttons()

    def refresh_lang_buttons(self):
        if self.lang == "es":
            self.btn_lang_es.config(relief="sunken")
            self.btn_lang_en.config(relief="raised")
        else:
            self.btn_lang_es.config(relief="raised")
            self.btn_lang_en.config(relief="sunken")

    # --------- Helpers GUI ----------
    def _short(self, path):
        if not path:
            return self.t("path_not_selected")
        norm = os.path.normpath(path)
        parts = norm.split(os.sep)
        if len(parts) > 4:
            return "..." + os.sep + os.path.join(*parts[-4:])
        return norm

    def log_write(self, text):
        self.log.configure(state="normal")
        self.log.insert("end", text + "\n")
        self.log.see("end")
        self.log.configure(state="disabled")
        self.root.update_idletasks()

    # --------- Acciones ----------
    def choose_folder(self):
        folder = filedialog.askdirectory(title=self.t("local_label"))
        if folder:
            self.cfg["local_path"] = folder
            self.path_label.config(text=self._short(folder))
            save_config(self.cfg)

    def update_engine(self):
        local = self.cfg.get("local_path", "").strip()
        branch = self.branch_var.get().strip() or DEFAULT_BRANCH
        self.cfg["branch"] = branch
        save_config(self.cfg)

        if not local:
            messagebox.showerror(self.t("msg_error_title"), self.t("msg_error_choose_folder"))
            return

        try:
            self.log_write(self.t("log_start_update"))
            perform_update(local, branch, self.log_write, self.lang)
            self.log_write(self.t("status_done"))
            messagebox.showinfo(self.t("msg_ok_title"), self.t("msg_ok_updated"))
        except requests.HTTPError as e:
            code = e.response.status_code if e.response is not None else "?"
            detail = str(e)
            msg = self.t("msg_error_http").format(code=code, detail=detail)
            self.log_write(msg)
            messagebox.showerror(self.t("msg_error_title"), msg)
        except Exception as e:
            detail = str(e)
            msg = self.t("msg_error_generic").format(detail=detail)
            self.log_write(msg)
            messagebox.showerror(self.t("msg_error_title"), msg)

    def show_help(self):
        messagebox.showinfo(self.t("help_title"), self.t("help_text"))

# ---------- Main ----------
if __name__ == "__main__":
    root = tk.Tk()
    app = UpdaterGUI(root)
    root.mainloop()
