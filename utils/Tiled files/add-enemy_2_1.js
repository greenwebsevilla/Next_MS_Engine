/* global tiled, Qt, MapObject, Layer, Dialog */

(function () {

  const VERSION = "2.1";
  const TOOL_ID = "EnemyPlacement";
  const TOOL_NAME = "NMSE Enemy Creator " + VERSION;
  const LAYER_NAME = "enemies";
  const MARKERS_LAYER = "_temp_markers";

  // ─────────────────────────────────────────────
  // 📝 Diálogo para configurar enemigo
  function pedirDatos(numero_sprite_base = 0) {
    const dlg = new Dialog("NMSE Enemy Creator " + VERSION);
    dlg.newRowMode = Dialog.SingleWidgetRows;
	dlg.minimumWidth = 300;

    dlg.addHeading("Define enemy properties", true);

    const inTipo = dlg.addNumberInput("Enemy type(*):");
    inTipo.decimals = 0; inTipo.singleStep = 1; inTipo.minimum = 1; inTipo.maximum = 255; inTipo.value = 1;
	
	let sprite_base_seleccionado = null;
	let inSprite = null;
	
	if (numero_sprite_base) {
		dlg.addLabel("✔ Base sprite selected: " + numero_sprite_base);
		sprite_base_seleccionado = numero_sprite_base;
    }else{
		inSprite = dlg.addNumberInput("Base sprite (0-63):");
    inSprite.decimals = 0; inSprite.singleStep = 1; inSprite.minimum = 0; inSprite.maximum = 63; inSprite.value = numero_sprite_base; 
	}
	
	const inLife = dlg.addNumberInput("Enemy life:");
    inLife.decimals = 0; inLife.singleStep = 1; inLife.minimum = 1; inLife.maximum = 63; inLife.value = 1;

    const inVel = dlg.addNumberInput("X speed (px/frame):");
    inVel.decimals = 0; inVel.singleStep = 1; inVel.minimum = -8; inVel.maximum = 8; inVel.value = 0;
  
	const inVelY = dlg.addNumberInput("Y speed (px/frame):");
    inVelY.decimals = 0; inVelY.singleStep = 1; inVelY.minimum = -8; inVelY.maximum = 8; inVelY.value = 0;

    dlg.addSeparator();

    const okBtn = dlg.addButton("OK");
    const cancelBtn = dlg.addButton("Cancel");

	dlg.addLabel("* To place the player, use type 255.");

	let result = null;
    okBtn.clicked.connect(() => {
		if (!sprite_base_seleccionado) sprite_base_seleccionado = Math.trunc(inSprite.value);
		
      result = {
        tipo: Math.trunc(inTipo.value),
        sprite: sprite_base_seleccionado,
        velocidad_x: Math.trunc(inVel.value),
        velocidad_y: Math.trunc(inVelY.value),
        life: Math.trunc(inLife.value)
      };
      dlg.accept();
    });
    cancelBtn.clicked.connect(() => { result = null; dlg.reject(); });

    const code = dlg.exec();
    if (code === Dialog.Accepted) return result;
    return null;
  }

  // ─────────────────────────────────────────────
  // 🧭 Capa de enemigos
  function ensureEnemiesLayer(map) {
    for (let i = 0; i < map.layerCount; ++i) {
      const layer = map.layerAt(i);
      if (layer.isObjectLayer && layer.name === LAYER_NAME) return layer;
    }
    const newLayer = new ObjectGroup(LAYER_NAME);
    newLayer.color = tiled.color("#ff3366");
    map.addLayer(newLayer);
    return newLayer;
  }

  // 🟩 Capa de marcadores (persistente)
  function ensureMarkersLayer(map) {
    for (let i = 0; i < map.layerCount; ++i) {
      const layer = map.layerAt(i);
      if (layer.isObjectLayer && layer.name === MARKERS_LAYER) return layer;
    }
    const newLayer = new ObjectGroup(MARKERS_LAYER);
    newLayer.color = tiled.color("#00ff00");
    map.addLayer(newLayer);
    return newLayer;
  }

  function tileTopLeftPx(map, tx, ty) {
    return { x: tx * map.tileWidth, y: ty * map.tileHeight };
  }
  
  
  function getTileset(map){
	  
      // --- Obtener tileset incluso si está embebido ---
      let ts = null;
	  let i = 0;
      if (map.tilesets && map.tilesets.length > 0) {
		while (i < map.tilesets.length){
			if (map.tilesets[i].name == "sprites"){ //Elegimos la capa de objetos 'sprites'
				ts = map.tilesets[i]; 
				break;
			}
			i++;
		}
		
      } else {
        // leer tilesets desde el documento JSON
        const doc = tiled.activeAsset;
        if (doc && doc.isTileMap && doc.asset && doc.asset.tilesets && doc.asset.tilesets.length > 0) {
          ts = null;
		  i = 0;
		  while (i < doc.asset.tilesets.length){
			
			if (doc.asset.tilesets[i].name == "sprites"){ //Elegimos la capa de objetos 'sprites'
				ts = doc.asset.tilesets[i]; 
				break;
			}
			i++;
		  }
		  
        }
      }

      if (!ts) {
        return;
      } else 
		  return ts;
  }

  // ─────────────────────────────────────────────
  // 🛠️ Herramienta principal
  const tool = tiled.registerTool(TOOL_ID, {
    name: TOOL_NAME,
    icon: "icon.png",

    activated() {
		
		this.tileset = getTileset(this.map);
		if (!this.tileset){
			tiled.alert("❌ ERROR!\n- No 'sprite' tileset found. Please, create a new tileset with all enemies sprites.\n- No se encontró el conjunto de patrones 'sprites', por favor, créalo con los sprites de los enemigos.");
			tiled.currentTool = "Select";   // ✅ desactiva la herramienta correctamente
			return;
		}
		
		this.step = 0;
		this.obj = null;
		this.points = [];
	  
		const editor = tiled.mapEditor;
		const view = editor ? editor.tilesetsView : null;
		const selected_tile = view ? view.selectedTiles[0] : null;

		// tiled.log(`✅ Tile selected: id=${tile.id}, tileset=${tile.tileset.name}`);
 
		if (selected_tile && selected_tile.tileset.name == "sprites") {
		  this.data = pedirDatos(selected_tile.id);
		}else
			this.data = pedirDatos();

      if (!this.data) {
        tiled.warn("Enemy creation cancelled.");
        tiled.currentTool = "Select";   // ✅ desactiva la herramienta correctamente
        return;
      }

      this.cursorShape = Qt.CrossCursor;
      this.statusInfo = "Click 1: spawn point (top-left corner).";

      if (this.map) this.map.selectedArea.set(Qt.rect(0, 0, 0, 0));
      ensureMarkersLayer(this.map);
    },

    deactivated() {
      if (this.map) this.map.selectedArea.set(Qt.rect(0, 0, 0, 0));
      this.points = [];
      this.step = 0;
    },

    updateEnabledState() {
      this.enabled = !!this.map;
    },

    tilePositionChanged() {
      if (!this.map) return;
      const tp = this.tilePosition;
      this.map.selectedArea.set(Qt.rect(tp.x, tp.y, 1, 1));
      this.updateStatusInfo();
    },

    updateStatusInfo() {
      if (!this.map) return;
      const tp = this.tilePosition;
      const w = this.map.tileWidth, h = this.map.tileHeight;
      const cx = tp.x * w + w / 2;
      const cy = tp.y * h + h / 2;
      const fase = ["spawn", "limit A", "limit B"][this.step] || "complete";
      this.statusInfo = `Tile (${tp.x},${tp.y}) center (${Math.trunc(cx)},${Math.trunc(cy)}) — Click for ${fase}.`;
    },

    // ──────────────────────────────
    // 🖱️ Click izquierdo → Colocar puntos
    mousePressed(button /*, x, y, modifiers */) {
      if (!this.map || button !== Qt.LeftButton || !this.data) return;

      const tp = this.tilePosition;
      const px = tileTopLeftPx(this.map, tp.x, tp.y);
      const tileW = this.map.tileWidth, tileH = this.map.tileHeight;

      this.points.push({ tileX: tp.x, tileY: tp.y, x: px.x, y: px.y });
      this.step++;

      const markerLayer = ensureMarkersLayer(this.map);
      let marker = new MapObject();

	let centerX = 0;
	let centerY = 0;

      if (this.step === 1) {
		// 🧍 Crear enemigo o Objeto para el player si es tipo 255
		if (this.data.tipo == 255){
			this.obj = new MapObject(MapObject.Ellipse, "Player");
			this.obj.className = "Player";
			// centerX = this.points[0].x + tileW/2;
			// centerY = this.points[0].y + tileH/2;			
			centerX = this.points[0].x;
			centerY = this.points[0].y;
			this.obj.penColor = "#0044CC";
			this.obj.brushColor = "#0066FF55";
			this.step = 2;
			
			
		}else{
			if (this.data.tipo == 50){
				this.obj = new MapObject(MapObject.Tile, "Collect Obj");
				this.step = 2;
			}else
				this.obj = new MapObject(MapObject.Tile, "Type "+this.data.tipo);
			
			this.obj.className = "Enemy";
			
			let tile = this.tileset.tiles[this.data.sprite];
			this.obj.tile = tile;
			centerX = this.points[0].x;
			centerY = this.points[0].y + tileH;
        }

		
		
        const grp = ensureEnemiesLayer(this.map);
		
		
		this.obj.x = centerX;
        this.obj.y = centerY;
		
		this.obj.width = tileW;
		this.obj.height = tileH;
		
        this.obj.setProperty("tipo", this.data.tipo);
        this.obj.setProperty("sprite", this.data.sprite);
        this.obj.setProperty("velocidad_x", this.data.velocidad_x);
        this.obj.setProperty("velocidad_y", this.data.velocidad_y);
        this.obj.setProperty("enem_life", this.data.life);
		grp.addObject(this.obj);
		
        this.statusInfo = "Click 2: limit A (top-left corner).";

      } else if (this.step === 2) {
        // 🔵 Límite A → rectángulo
        marker.shape = MapObject.Rectangle;
        marker.x = px.x;
        marker.y = px.y;
        marker.width = tileW;
        marker.height = tileH;
        marker.name = "Limit A";
        marker.penColor = "#0044CC";
        marker.brushColor = "#0066FF55";
        markerLayer.addObject(marker);
        this.statusInfo = "Click 3: limit B (bottom-right corner).";
		this.markerA = marker;
		
      } else if (this.step === 3) {
		
		if (this.data.tipo !== 255 && this.data.tipo !== 50){
		  
        // 🔴 Límite B → rectángulo
        marker.shape = MapObject.Rectangle;
        marker.x = px.x;
        marker.y = px.y;
        marker.width = tileW;
        marker.height = tileH;
        marker.name = "Limit B";
        marker.penColor = "#CC0000";
        marker.brushColor = "#FF000055";
        markerLayer.addObject(marker);
		this.markerB = marker;
		
        //Definir los puntos limites
		const spawn = this.points[0];
        const limA = this.points[1];
        const limB = this.points[2];
		
		// 📝 Conversión a coordenadas de tile
		const spawnTileX = Math.floor(spawn.x / this.map.tileWidth);
		const spawnTileY = Math.floor(spawn.y / this.map.tileHeight);
		const limit1TileX = Math.floor(limA.x / this.map.tileWidth);
		const limit1TileY = Math.floor(limA.y / this.map.tileHeight);
		const limit2TileX = Math.floor(limB.x / this.map.tileWidth);
		const limit2TileY = Math.floor(limB.y / this.map.tileHeight);
		
		// Calcular número de pantalla (solo para pantallas de 20x10 tiles)
		const num_pantallas_ancho = Math.floor(this.map.width / 20);
		const num_pantallas_alto = Math.floor(this.map.height / 10);
		const enem_num_columna = Math.floor(spawnTileX / 20);
		const enem_num_fila = Math.floor(spawnTileY / 10);
		const enem_num_pantalla = Math.floor(enem_num_columna + enem_num_fila*num_pantallas_ancho);
		
		// 📌 Número de pantalla en la que está el enemigo (pantallas de 20x10 tiles)
		this.obj.setProperty("num_pantalla", enem_num_pantalla);
		
		// Enlazar con los objetos limite A y B
		this.obj.setProperty("limitA", this.markerA);
		this.obj.setProperty("limitB", this.markerB);
		}
		
		this.map.selectedObjects = [this.obj];


		if (this.data.tipo !== 255)
			tiled.alert(
			  `✅ Enemy created!`
        );
		else
			tiled.alert(
			  `✅ Player position created`
			);
		
        // 📝 Pedir nuevos parámetros para siguiente enemigo
		const editor = tiled.mapEditor;
		const view = editor ? editor.tilesetsView : null;
		const selected_tile = view ? view.selectedTiles[0] : null;
        
		// Detectamos si estaba seleccionado el sprite en el tileset
		let nextData;
		if (selected_tile && selected_tile.tileset.name == "sprites") {
			nextData = pedirDatos(selected_tile.id);
		}else
			nextData = pedirDatos();
		
        if (nextData) {
          this.data = nextData;
          this.points = [];
          this.step = 0;
          this.map.selectedArea.set(Qt.rect(0, 0, 0, 0));
          this.statusInfo = "Click 1: spawn point (top-left corner).";
        } else {
		  // Cancelar → volver a herramienta de selección
		  this.data = null;
		  this.points = [];
		  this.step = 0;
		  this.statusInfo = "❌ Enemy insertion cancelled.";
		  tiled.currentTool = "Select";   // ✅ esto desactiva el botón y vuelve a "Select"
		}

      }
    },

    // 🖱️ Click derecho → cancelar colocación parcial
    mouseRightPressed() {
      if (this.points.length > 0) {
        this.points = [];
        this.step = 0;
        this.map.selectedArea.set(Qt.rect(0, 0, 0, 0));
        this.statusInfo = "❌ Cancelled. Click 1: spawn point.";
      }
    }
  });

})();
