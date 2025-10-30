# Next MS Engine

**Next MS Engine** es un motor para hacer juegos para ***ZX Spectrum Next***. Está programado en Boriel's ZX Basic (de Jose Rodriguez) más las librerías Nextlib de em00k (David Saphier). Además, se incluyen las herramientas necesarias para crear los ficheros gráficos y mapas y exportarlos al formato que maneja el propio motor. 

El origen de este motor es una versión reducida y reprogramada del motor MK1 de los Mojon Twins que sirvió para portar el juego Shovel Adventure al Spectrum Next. Partiendo de él, se fueron añadiendo funcionalidades extra, algunas también existentes en el MK1 pero hechas desde cero en el lenguaje ZX Basic y aprovechando las características del Next.

# Características del motor:

 - Configuración del player: velocidades, salto, gravedad, disparo, energía, vidas, inercia, caja de colisión, etc
 - Manejo de mapas de hasta 256 tiles de ancho (4096 píxeles) y de altura hasta 12 tiles (192 píxeles)
 - Scroll horizontal (proximamente también vertical).
 - Configuración de la cámara.
 - Conexión entre mapas personalizables. 
 - Hasta 128 imágenes de 16x16 para el player.
 - Hasta 128 imágenes de 16x16 para enemigos y objetos por mapa.
 - Posibilidad de usar sprites de 16x32.
 - Configuración de enemigos.
 - 4 tipos de enemigos preprogramados.
 - Plataformas móviles y objetos recolectables preprogramados.
 - Personalización del hud.
 - Tile animados para tener fondos más atractivos.
 - Temporizador.


# Como empezar

Para trabajar necesitaremos descargar lo siguiente:

**- Nextbuild**: contiene las librerías Nextlibs, el compilador ZX Basic de Boriel y el emulador CSpect. Descarga la versión 7 aqui: https://github.com/em00k/NextBuild

**- Visual Studio Code**: será nuestro editor de código y desde el que abriremos nuestro motor para aprovechar todas las ventajas que nos brinda Nextbuild. Descargalo gratis de aqui: https://code.visualstudio.com/download

**-Tiled map editor**: lo usaremos para crear nuestros mapas y colocar enemigos, al jugador y objetos en él. Se puede bajar gratuitamente desde: https://www.mapeditor.org/download.html

**- Aseprite**: este editor y animador de pixel art es el que recomiendo. Es de pago, pero merece muchísimo la pena pagar por él si vas a trabajar con ficheros dirigidos al Next, ya que tenemos además una serie de plugins exclusivos para el manejo de paletas, exportar a formatos Next y convertir imágenes a la paleta del Next. 
Cómpralo y descárgalo aquí: https://www.aseprite.org/

Si no quieres usar Aseprite y prefieres tu editor de confianza, deberás tratar tus gráficos en la herramienta online de Remy Sharp: https://zx.remysharp.com/sprites/ para exportarlas en el formato correcto. Es igual de válido pero personalmente, habiendo trabajado con ambas opciones, prefiero tener todo en Aseprite y no depender de una conexión a internet. También es cierto que Remy tiene algunas herramientas extra interesantes como el editor de sonidos FX, creador de ficheros BAS, etc. 

**- Plugins para Aseprite** by Pandapus (Paul "Spectre" Harten). Descárgalos de https://github.com/spectrepaul/blog/tree/main/ZX%20Spectrum%20Next%20-%20Using%20Aseprite
Y visita la web del autor para saber que nos ofrecen esos plugins: https://www.pandapus.com/2025/09/zx-spectrum-next-using-aseprite.html

