<p align="center">
  <img src="media/header.jpg" alt="Americas Language Pack: Español Latino, Português (Brasil) and US English for Bloodborne GOTY on shadPS4 and BBPort" width="100%">
</p>

<p align="center">
  <b>Bloodborne GOTY</b> (EU, CUSA03173) &nbsp;·&nbsp; <b>shadPS4 + BBLauncher</b> &nbsp;·&nbsp; <b>BBPort</b><br>
  Play in your language and keep online features: no <i>Unlock Game Region</i> patch needed.<br>
  Juega en tu idioma sin perder el online: no necesitas el parche <i>Unlock Game Region</i>.<br>
  Jogue com legendas e dublagem em português do Brasil sem perder o online.
</p>

<p align="center">
  <a href="../../releases/latest/download/Americas-Language-Pack.zip"><img src="media/download.png" alt="Download / Descargar" width="300"></a>
</p>

<p align="center">
  <a href="#english">English</a> &nbsp;·&nbsp; <a href="#español">Español</a> &nbsp;·&nbsp; <a href="../../releases">All versions / Todas las versiones</a> &nbsp;·&nbsp; <a href="https://www.nexusmods.com/bloodborne/mods/578">Nexus Mods</a>
</p>

> [!TIP]
> **New in v1.1:** it also works with **BBPort**, the native PC port. The same installer detects BBLauncher or BBPort by itself.
>
> **Nuevo en la v1.1:** también funciona con **BBPort**, el port nativo para PC. El mismo instalador detecta solo BBLauncher o BBPort.

<p align="center">
  <img src="media/showcase.jpg" alt="The game's Language menu set to Latin American Spanish, Brazilian Portuguese and US English, and a message from the online server in Latin American Spanish" width="100%">
</p>

<details>
<summary>📸 <b>Full screenshots</b> · Capturas completas</summary>
<br>
<table>
  <tr>
    <td><img src="media/menu-es-latam.jpg" alt="Language menu in Latin American Spanish" width="380"></td>
    <td><img src="media/menu-pt-br.jpg" alt="Language menu in Brazilian Portuguese" width="380"></td>
  </tr>
  <tr>
    <td><img src="media/menu-en-us.jpg" alt="Language menu in US English" width="380"></td>
    <td><img src="media/online-es-latam.jpg" alt="A message from another player, from the online server, in Latin American Spanish" width="380"></td>
  </tr>
</table>
</details>

## English

The European GOTY already has the languages of the Americas, but its Language menu only shows the European ones. This pack adds them to the game's own menu **without touching the region**, so online play keeps working.

- 🌐 **Online keeps working:** no *Unlock Game Region* patch, so messages, bloodstains and specters stay on.
- 🎙️ **Text and voices** in Spanish (Latin America) and Portuguese (Brazil), **text** in US English.
- 🎮 **Real options in the Language menu,** with the game's official names. English (UK) and the other European languages stay.
- 🖥️ **BBPort too:** there it adds the Latin American Spanish text. BBPort already has Brazilian Portuguese and the Latin American voices.
- 📦 **No game files in the download:** the installer builds the mod from your own copy, and your game folder is never modified.

**Requirements:** Windows 10/11 · Bloodborne GOTY EU (CUSA03173) v1.09 dumped from your own copy, as a folder (not .zar) · shadPS4 + BBLauncher, or [BBPort](https://github.com/Supermedo/bloodborne_pc)

### Install with BBLauncher (shadPS4)

1. Click **Download** above and extract the zip.
2. Drag the **Americas Language Pack v1.1** folder into your BBLauncher folder (the one with BB_Launcher.exe), not into Mods.
3. Open it and double-click **INSTALL - Americas Language Pack.bat** (keep the .ps1 next to it). Wait until it says **DONE** (or LISTO).
4. BBLauncher > Mod Manager > Inactive Mods > **Americas Language Pack** > Activate Mod.
5. In the game: OPTIONS > System > Language > pick your language in Text and in Voice.

> [!IMPORTANT]
> For online play keep the **Unlock Game Region** and **Disable HTTP Requests** patches OFF.

### Install with BBPort

1. Click **Download** above and extract the zip.
2. Drag the **Americas Language Pack v1.1** folder into your BBPort folder (the one with Bloodborne.exe), not into mods.
3. Open it and double-click **INSTALL - Americas Language Pack.bat**. It finds your game and puts the mod in BBPort's mods folder. Wait until it says **DONE** (or LISTO).
4. BBPort > Game & effects > Text language: **Spanish** (now Latin American) · Voice language: **Español (América)**.

<details>
<summary><b>Uninstall</b></summary>
<br>

**BBLauncher:** in the game, set Text and Voice back to "Default". Then BBLauncher > Mod Manager > Active Mods > Americas Language Pack > Deactivate Mod, and delete its folder from BBLauncher's Mods folder.

**BBPort:** untick Americas Language Pack in Mods & patches, or delete its folder from BBPort's mods folder.

Step by step in README.txt, section 9.

</details>

<details>
<summary><b>Compatibility and known limitations</b></summary>
<br>

- Works with patches and mods that don't change the game's text, font or voice files (60 FPS, resolution, graphics...).
- It doesn't work with other language or text mods: if BBLauncher shows "Mod conflict found", deactivate the other mod first.
- While the mod is active, Spanish (Latin America) takes the place of Italian, Portuguese (Brazil) of German, and English (United States) of Danish.
- US English is text only: for Voice keep English (United Kingdom), it's the same dub.
- "Default" doesn't pick the new languages: choose them yourself in Text and Voice.
- It also fixes two small mistakes in the official language names ("Pulir" instead of "Polaco" in Latin American Spanish, and "Brasil" in English).
- **On BBPort:** Spanish (Latin America) takes the place of Spanish (Spain), text only. Untick the mod to get Spain's Spanish back. BBPort's "Quit to Desktop" stays in the menu; if you turn that option on or off later, run the installer again.
- Made and tested for Supermedo's BBPort (v1.9.2). Other forks and ports aren't supported.
- Using shadPS4 and BBPort with the same game folder? BBPort also loads BBLauncher's active mods, so deactivate the pack in BBLauncher before playing on BBPort.

</details>

<details>
<summary><b>Safety and antivirus</b></summary>
<br>

- **Official pages:** this GitHub page and the [Nexus Mods page](https://www.nexusmods.com/bloodborne/mods/578). Both have the same file. Don't download it from links posted by other people.
- Every release lists the zip's SHA-256 and its VirusTotal scan.
- The installer is plain-text PowerShell that anyone can read ([read it here](Americas%20Language%20Pack/Americas_Language_Pack.ps1)). It only reads your game files and the settings of BBLauncher or BBPort, and writes the mod folder: no internet connections, no changes to Windows.
- Some antivirus programs (Bitdefender, for example) may flag it with a generic heuristic detection such as "Heur...Boxter", a common false positive for installers written as scripts. You don't need to turn off your protection: add an exception for the installer folder (README.txt, section 11).

</details>

📖 README.txt (inside the zip, English and Spanish) covers every step, shadPS4 without BBLauncher, troubleshooting and FAQ.

## Español

La GOTY europea ya trae los idiomas de América, pero su menú Idioma solo muestra los europeos. Este pack los agrega al menú del propio juego **sin tocar la región**, así que el online sigue funcionando.

- 🌐 **El online sigue funcionando:** sin el parche *Unlock Game Region*, así que los mensajes, las manchas de sangre y los espectros siguen ahí.
- 🎙️ **Texto y voces** en español (América Latina) y portugués (Brasil); **texto** en inglés de EE. UU.
- 🎮 **Opciones reales en el menú Idioma,** con los nombres oficiales del juego. El inglés (Reino Unido) y los demás idiomas europeos se quedan.
- 🖥️ **También en BBPort:** ahí agrega el texto en español latino. BBPort ya trae el portugués de Brasil y las voces latinas.
- 📦 **La descarga no trae archivos del juego:** el instalador crea el mod a partir de tu propia copia, y la carpeta de tu juego nunca se modifica.

**Requisitos:** Windows 10/11 · Bloodborne GOTY EU (CUSA03173) v1.09 dumpeado de tu propia copia, como carpeta (no .zar) · shadPS4 + BBLauncher, o [BBPort](https://github.com/Supermedo/bloodborne_pc)

### Instalación con BBLauncher (shadPS4)

1. Dale clic a **Descargar** arriba y extrae el zip.
2. Arrastra la carpeta **Americas Language Pack v1.1** a tu carpeta de BBLauncher (la que tiene BB_Launcher.exe), no a Mods.
3. Ábrela y dale doble clic a **INSTALL - Americas Language Pack.bat** (deja el .ps1 junto). Espera a que diga **LISTO** (o DONE).
4. BBLauncher > Mod Manager > Inactive Mods > **Americas Language Pack** > Activate Mod.
5. En el juego: OPTIONS > Sistema > Idioma > elige tu idioma en Texto y en Voz.

> [!IMPORTANT]
> Para el online deja APAGADOS los parches **Unlock Game Region** y **Disable HTTP Requests**.

### Instalación con BBPort

1. Dale clic a **Descargar** arriba y extrae el zip.
2. Arrastra la carpeta **Americas Language Pack v1.1** a tu carpeta de BBPort (la que tiene Bloodborne.exe), no a mods.
3. Ábrela y dale doble clic a **INSTALL - Americas Language Pack.bat**. Encuentra tu juego y pone el mod en la carpeta mods de BBPort. Espera a que diga **LISTO** (o DONE).
4. BBPort > Juego y efectos (Game & effects) > Text language: **Español** (ahora latino) · Voice language: **Español (América)**.

<details>
<summary><b>Desinstalar</b></summary>
<br>

**BBLauncher:** en el juego regresa Texto y Voz a "Predeterminado". Luego BBLauncher > Mod Manager > Active Mods > Americas Language Pack > Deactivate Mod, y borra su carpeta de la carpeta Mods de BBLauncher.

**BBPort:** desmarca Americas Language Pack en Mods y parches, o borra su carpeta de la carpeta mods de BBPort.

Paso a paso en el README.txt, sección 9.

</details>

<details>
<summary><b>Compatibilidad y limitaciones conocidas</b></summary>
<br>

- Funciona con parches y mods que no cambien los archivos de texto, fuentes o voces del juego (60 FPS, resolución, gráficos...).
- No es compatible con otros mods de idioma o de texto: si BBLauncher dice "Mod conflict found", desactiva primero el otro mod.
- Mientras el mod está activo, el español (América Latina) ocupa el lugar del italiano, el portugués (Brasil) el del alemán y el inglés (Estados Unidos) el del danés.
- Inglés (Estados Unidos) es solo texto: en Voz deja Inglés (Reino Unido), es el mismo doblaje.
- "Predeterminado" no elige los idiomas nuevos: elígelos tú en Texto y en Voz.
- También corrige dos errores en los nombres oficiales de los idiomas ("Pulir" en lugar de "Polaco" en el texto latino, y "Brasil" en inglés).
- **En BBPort:** el español (América Latina) ocupa el lugar del español de España, solo texto. Desmarca el mod para tener de vuelta el de España. "Salir al escritorio" de BBPort se queda en el menú; si después prendes o apagas esa opción, vuelve a correr el instalador.
- Hecho y probado para el BBPort de Supermedo (v1.9.2). Otros forks y ports no están soportados.
- ¿Usas shadPS4 y BBPort con la misma carpeta del juego? BBPort también carga los mods activos de BBLauncher, así que desactiva el pack en BBLauncher antes de jugar en BBPort.

</details>

<details>
<summary><b>Seguridad y antivirus</b></summary>
<br>

- **Páginas oficiales:** esta página de GitHub y la [página de Nexus Mods](https://www.nexusmods.com/bloodborne/mods/578). Las dos tienen el mismo archivo. No lo descargues de links que publiquen otras personas.
- Cada versión indica el SHA-256 del zip y su análisis de VirusTotal.
- El instalador es PowerShell en texto plano que cualquiera puede leer ([léelo aquí](Americas%20Language%20Pack/Americas_Language_Pack.ps1)). Solo lee los archivos de tu juego y la configuración de BBLauncher o de BBPort, y escribe la carpeta del mod: no se conecta a internet ni cambia nada de Windows.
- Algunos antivirus (Bitdefender, por ejemplo) pueden marcarlo con una detección heurística genérica como "Heur...Boxter", un falso positivo común en instaladores hechos como script. No necesitas apagar tu protección: agrega una excepción para la carpeta del instalador (README.txt, sección 11).

</details>

📖 El README.txt (dentro del zip, en inglés y español) trae cada paso, cómo usarlo solo con shadPS4, solución de problemas y preguntas frecuentes.

---

<p align="center">
  <b>Created by Rammsiris - Game Developer</b><br>
  <sub>Thanks to the shadPS4 team, the BBLauncher developer and Supermedo (BBPort) · Gracias al equipo de shadPS4, al desarrollador de BBLauncher y a Supermedo (BBPort)</sub>
</p>

<p align="center"><sub>Unofficial fan-made mod, not affiliated with or endorsed by Sony Interactive Entertainment, FromSoftware, shadPS4, BBLauncher or BBPort. Bloodborne © Sony Interactive Entertainment. This mod includes no game files. Provided as is, without warranty. Please don't re-upload it to other sites: share the link to this page or to its Nexus Mods page instead.</sub></p>

<p align="center"><sub>Mod no oficial hecho por fans, sin afiliación ni aval de Sony Interactive Entertainment, FromSoftware, shadPS4, BBLauncher ni BBPort. Bloodborne © Sony Interactive Entertainment. Este mod no incluye archivos del juego. Se ofrece tal cual, sin garantía. Por favor no lo resubas a otros sitios: comparte el link de esta página o de su página en Nexus Mods.</sub></p>
