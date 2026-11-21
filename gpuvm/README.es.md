[English](README.md) | Español

# Sunshine de GpuVM

El Sunshine de GpuVM es un fork de [Sunshine](https://github.com/LizardByte/Sunshine) (GPL-3.0) en `v2026.914.233613`.
GpuVM instala el MSI original en cada máquina y luego pone encima dos archivos de este fork: `sunshine.exe` y
`tools\sunshine_wgc_capture.exe`. Todo lo demás queda como lo escribió el proyecto original.

## Por qué

En las máquinas Hyper-V con GPU-P y pantalla virtual, Desktop Duplication pierde el acceso después de cada cuadro
(lab 055 de GpuVM), así que el visor queda en negro. Windows.Graphics.Capture funciona, pero solo para el usuario de
la sesión de consola: Sunshine corriendo como SYSTEM no puede usarlo, y correr Sunshine como ese usuario le daría las
claves de Sunshine. Este fork permite que el servicio de SYSTEM capture con WGC mediante un ayudante pequeño que corre
como el usuario que inició sesión y no guarda nada secreto.

## Qué cambia respecto del original

| Archivo | Cambio |
|---|---|
| `tools/sunshine_wgc_capture.cpp` | El ayudante de captura, de [Vibeshine](https://github.com/Nonary/vibeshine) (GPL-3.0, commit `95254e2`). Captura con WGC y publica los cuadros en una textura compartida con keyed mutex. |
| `src/platform/windows/ipc/*`, `wgc_capture_policy.h` | La IPC de Vibeshine (pipes, lanzador de procesos, sesión). El lanzador solo usa el token sin elevar del usuario de consola: se quitó el respaldo como SYSTEM de Vibeshine. |
| `src/platform/windows/display.h`, `display_wgc.cpp`, `display_vram.cpp` | `display_wgc_*_t` eligen su fuente de cuadros al iniciar: el ayudante como SYSTEM, WGC en el mismo proceso en otro caso. |
| `tools/CMakeLists.txt`, `cmake/compile_definitions/windows.cmake` | Compilan el ayudante y la IPC. |
| `cmake/packaging/windows.cmake` | `GPUVM_SKIP_WIX` (GpuVM no usa el MSI). |
| `build-gpuvm.*`, `build-target.sh` | Compilación en MSYS2 UCRT64: sin docs, pruebas ni bandeja (ninguna interfaz de un proceso SYSTEM en el escritorio del usuario). |

El primer commit después de la etiqueta original importa los archivos de Vibeshine sin cambios; los siguientes
muestran cada cambio.

### Cambios en el ayudante

- **Dispositivo D3D11 protegido para varios hilos.** El frame pool de hilos libres, el callback de FrameArrived y el
  hilo de entrega comparten un dispositivo; sin protección, la captura se detenía para siempre después de 1-2,5
  minutos en una pantalla virtual con GPU-P.
- **Vigilante de bloqueos.** Un hilo trabado 5 s dentro de una copia o de un bloqueo termina el ayudante, y Sunshine
  arranca uno nuevo (imagen otra vez en un segundo, en vez de congelada). Un ayudante sin trabajo con la pantalla
  quieta no se toca.
- **Vigilancia del servicio de captura.** Las sesiones de WGC viven en el `CaptureService` de cada usuario de Windows.
  Si se cae, Windows lo reinicia, pero una sesión abierta antes no recibe el evento Closed ni más cuadros. El ayudante
  anota el proceso del servicio al empezar a capturar y vuelve a empezar si cambia (imagen de vuelta en unos 2 s).
- **Copia terminada antes de devolver el cuadro.** Cada copia desde un búfer de WGC espera a la GPU (una consulta de
  evento, 50 ms como máximo) antes de soltar el cuadro, para que Windows no dibuje el siguiente en un búfer que
  todavía se está copiando.
- **Solo cuadros terminados.** En una pantalla con GPU-P Windows puede entregar un cuadro mientras todavía lo dibuja:
  lo que cambió se limpia a negro transparente y se dibuja después, y el stream mostraba franjas, cuñas o la pantalla
  negra durante un cuadro. Un cuadro de escritorio terminado es opaco, así que cada copia se revisa en la GPU (una
  cadena de mipmaps, ~2 KB leídos); bloques que quedan transparentes donde el cuadro anterior era opaco indican que no
  está terminado, y el ayudante vuelve a copiar cada 0,5 ms (el cuadro sigue retenido, así que Windows lo termina en
  su lugar; casi siempre en menos de 1 ms), 25 ms como máximo. El contenido de verdad transparente (algunos juegos) se
  toma tras esa única espera y pasa a ser la referencia. `tools\gpuvm-frame-check-off.txt` la desactiva.
- **Un log por ejecución.** `%APPDATA%\Sunshine\wgc-helper\helper-<fecha>-<pid>.log`, se guardan los 40 más nuevos
  (Sunshine arranca el ayudante varias veces mientras se abre un visor).

## Compilar (Windows)

Requisitos: MSYS2 en `C:\msys64` con los paquetes UCRT64 de `docs/building.md` más `libtiff` y `nlohmann-json`, y
Node.js en el PATH (interfaz web).

```powershell
git submodule update --init --recursive
.\build-gpuvm.ps1
.\gpuvm\publish.ps1   # copia los dos archivos que GpuVM incluye en ..\gpu-vm\sunshine
```

## Seguir al proyecto original

```powershell
git fetch upstream --tags
git rebase --onto vX.Y.Z v2026.914.233613 gpuvm
```

Después, en GpuVM, actualiza `streaming/components.json` a la misma versión original (el `sunshine.exe` del fork
reemplaza al del MSI), compila y corre el lab 055 de GpuVM (`open.ps1` en una copia de agente) antes de publicar.

## Licencia

GPL-3.0, como Sunshine y Vibeshine. Se publica el código de cada build que GpuVM incluye. GpuVM (MIT) es un programa
aparte.
