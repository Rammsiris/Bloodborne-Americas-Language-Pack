<#
.SYNOPSIS
    Americas Language Pack v1.2 for Bloodborne on shadPS4 (+ BBLauncher) or BBPort.

.DESCRIPTION
    Adds Latin American Spanish, Brazilian Portuguese and US English to the
    Language menu of the European Game of the Year Edition (CUSA03173),
    without the "Unlock Game Region" patch, so online play keeps working.

    The European disc already contains these languages, but its Language
    menu only lists the European ones. This script leaves the region alone
    and puts each of them in the place of a European language, renaming
    that menu entry:

        Spanish (Latin America)   text + voices  -> replaces Italian
        Portuguese (Brazil)       text + voices  -> replaces German
        English (United States)   text           -> replaces Danish

    It reads the game files and writes a new mod folder for BBLauncher.
    The game folder itself is never changed.

    On BBPort (the native Windows port) the language is set in its launcher.
    There the script writes a text-only mod to BBPort's mods folder that puts
    Latin American Spanish text in place of Spanish (Spain), with the texts
    BBPort adds to the menu (Quit to Desktop, Rebirth at the Doll). BBPort
    already has the Latin American Spanish voices and Brazilian Portuguese.

.EXAMPLE
    Double-click "INSTALL - Americas Language Pack.bat" in this folder.
    See README.txt for details.

.NOTES
    Created by Rammsiris - Game Developer
    Version 1.2
#>
param(
    [string]$GameFolder = '',
    [ValidateSet('', 'es', 'en')][string]$Language = '',
    [switch]$NoPause
)

$ErrorActionPreference = 'Stop'
$script:ModName    = 'Americas Language Pack'
$script:ModVersion = '1.2'
$script:Author     = 'Rammsiris'
$script:ActiveName = 'Mods-Active (DO NOT DELETE)'
$script:Building   = $null

# Languages added by this pack and the European slot each one takes over.
#   Text / Voice     : folder / voice-file suffix of the added language on the disc
#   Slot / SlotVoice : folder / voice-file suffix of the European language it replaces
#   LabelSlot / Label: menu entry that gets renamed / menu entry whose text it receives
$script:Packs = @(
    [pscustomobject]@{ Es = 'Español (Latinoamérica)'; En = 'Spanish (Latin America)'; Text = 'spaar'; Voice = 'esa'; Slot = 'itait'; SlotVoice = 'iti'; LabelSlot = 115103; Label = 115106; OldEs = 'Italiano'; OldEn = 'Italian' },
    [pscustomobject]@{ Es = 'Portugués (Brasil)';      En = 'Portuguese (Brazil)';     Text = 'porbr'; Voice = 'ptb'; Slot = 'deude'; SlotVoice = 'ded'; LabelSlot = 115104; Label = 115107; OldEs = 'Alemán';   OldEn = 'German' },
    [pscustomobject]@{ Es = 'Inglés (Estados Unidos)'; En = 'English (United States)'; Text = 'engus'; Voice = $null; Slot = 'dandk'; SlotVoice = $null; LabelSlot = 115112; Label = 115108; OldEs = 'Danés';    OldEn = 'Danish' }
)

# BBPort sets the text language in its launcher, so there only the Latin
# American Spanish text is added, in place of Spanish (Spain): "Spanish" in
# BBPort's launcher then shows it (and the game's Language list says so).
$script:PortPack = [pscustomobject]@{ Es = 'Español (Latinoamérica)'; En = 'Spanish (Latin America)'; Text = 'spaar'; Voice = $null; Slot = 'spaes'; SlotVoice = $null; LabelSlot = 115105; Label = 115106; OldEs = 'Español (España)'; OldEn = 'Spanish (Spain)' }

# Text languages listed in the European Language menu (their language names get renamed too).
$script:EuSlots = @('enggb', 'frafr', 'itait', 'deude', 'spaes', 'nldnl', 'polpl', 'rusru', 'dandk', 'norno', 'finfi', 'swese', 'turtr', 'porpt')

# Small fixes in the official language names:
#   Latin American Spanish calls Polish "Pulir" (to polish) and leaves German in
#   English; English writes "Brasil".
$script:Fixes = @(
    [pscustomobject]@{ Source = 'spaar'; Id = 115110; Old = 'Pulir';               New = 'Polaco' },
    [pscustomobject]@{ Source = 'spaar'; Id = 115104; Old = 'German';              New = 'Alemán' },
    [pscustomobject]@{ Source = 'enggb'; Id = 115107; Old = 'Portuguese (Brasil)'; New = 'Portuguese (Brazil)' },
    [pscustomobject]@{ Source = 'engus'; Id = 115107; Old = 'Portuguese (Brasil)'; New = 'Portuguese (Brazil)' }
)

# Console language: Spanish if Windows uses Spanish, English otherwise (or -Language es/en).
$script:Es = $false
try {
    $script:Es = ((Get-UICulture).TwoLetterISOLanguageName -eq 'es') -or ((Get-Culture).TwoLetterISOLanguageName -eq 'es')
} catch { }
if ($Language -eq 'es') { $script:Es = $true }
if ($Language -eq 'en') { $script:Es = $false }

function T([string]$es, [string]$en) {
    if ($script:Es) { return $es } else { return $en }
}

function Say([string]$text, [string]$color = 'Gray') {
    Write-Host $text -ForegroundColor $color
}

# Folder picker window, opened at $start. Returns '' if the user clicks Cancel.
function Select-Folder([string]$description, [string]$start = '') {
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        $owner = New-Object System.Windows.Forms.Form
        $owner.TopMost = $true
        $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $dialog.Description = $description
        $dialog.ShowNewFolderButton = $false
        if ($start -and [IO.Directory]::Exists($start)) { $dialog.SelectedPath = $start }
        $result = $dialog.ShowDialog($owner)
        $owner.Dispose()
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) { return $dialog.SelectedPath }
        return ''
    } catch {
        Say $description
        $typed = Read-Host (T 'Pega aquí la ruta de la carpeta y presiona Enter (vacío = cancelar)' 'Paste the folder path here and press Enter (empty = cancel)')
        if ($null -eq $typed) { return '' }
        return $typed.Trim().Trim('"')
    }
}

# =============================================================================
#  BBLauncher and game folders
# =============================================================================

# BBLauncher keeps its settings and mods in a "BBLauncher" folder next to
# BB_Launcher.exe. Looks in $start and up to $levels parent folders and
# returns that "BBLauncher" folder, or '' if it isn't there.
function Find-Launcher([string]$start, [int]$levels) {
    $dir = $start
    for ($i = 0; $i -le $levels -and $dir; $i++) {
        $data = [IO.Path]::Combine($dir, 'BBLauncher')
        if ([IO.File]::Exists([IO.Path]::Combine($dir, 'BB_Launcher.exe')) -or
            [IO.File]::Exists([IO.Path]::Combine($dir, 'BBLauncher.exe')) -or
            [IO.File]::Exists([IO.Path]::Combine($data, 'LauncherSettings.toml')) -or
            [IO.Directory]::Exists([IO.Path]::Combine($data, 'Mods'))) {
            return $data
        }
        $dir = [IO.Path]::GetDirectoryName($dir)
    }
    return ''
}

# BBPort keeps Bloodborne.exe next to "Play Bloodborne.exe", bbport.ini or its
# launcher folder. Looks in $start and up to $levels parent folders and
# returns that folder, or '' if it isn't there.
function Find-Port([string]$start, [int]$levels) {
    $dir = $start
    for ($i = 0; $i -le $levels -and $dir; $i++) {
        if ([IO.File]::Exists([IO.Path]::Combine($dir, 'Bloodborne.exe')) -and (
            [IO.File]::Exists([IO.Path]::Combine($dir, 'Play Bloodborne.exe')) -or
            [IO.File]::Exists([IO.Path]::Combine($dir, 'bbport.ini')) -or
            [IO.Directory]::Exists([IO.Path]::Combine($dir, 'launcher')))) {
            return $dir
        }
        $dir = [IO.Path]::GetDirectoryName($dir)
    }
    return ''
}

# BBPort's launcher settings (%APPDATA%\bbport-launcher\settings.json), or $null.
function Get-PortSettings {
    try {
        if (-not $env:APPDATA) { return $null }
        $file = [IO.Path]::Combine($env:APPDATA, 'bbport-launcher', 'settings.json')
        if (-not [IO.File]::Exists($file)) { return $null }
        return ([IO.File]::ReadAllText($file) | ConvertFrom-Json)
    } catch {
        return $null
    }
}

# The game folder chosen in BBPort's launcher, or the one it uses by default
# (CUSA03173 next to the BBPort folder).
function Get-PortGamePath([string]$port, $settings) {
    if ($settings -and $settings.game_dir -and "$($settings.game_dir)".Trim()) { return "$($settings.game_dir)".Trim() }
    return [IO.Path]::Combine([IO.Path]::GetDirectoryName($port), 'CUSA03173')
}

# Where BBPort keeps bbport.ini, mods.json and its default mods folder: next
# to Bloodborne.exe (or BB_DATA_DIR, if set).
function Get-PortDataFolder([string]$port) {
    if ($env:BB_DATA_DIR -and $env:BB_DATA_DIR.Trim()) { return $env:BB_DATA_DIR.Trim() }
    return $port
}

# The folder BBPort loads mods from: the one chosen in its launcher, or
# "mods" next to Bloodborne.exe (BBPort doesn't create it until it's needed).
function Get-PortModsFolder([string]$port, $settings) {
    if ($settings -and $settings.mods_dir -and "$($settings.mods_dir)".Trim()) { return "$($settings.mods_dir)".Trim() }
    return [IO.Path]::Combine((Get-PortDataFolder $port), 'mods')
}

# APP_VER of the game's sce_sys\param.sfo ("01.09"), or '' if it can't be read.
function Get-GameVersion([string]$game) {
    try {
        $b = [IO.File]::ReadAllBytes([IO.Path]::Combine($game, 'sce_sys', 'param.sfo'))
        if ($b.Length -lt 0x14 -or $b[0] -ne 0 -or $b[1] -ne 0x50 -or $b[2] -ne 0x53 -or $b[3] -ne 0x46) { return '' }
        $keys = [BitConverter]::ToInt32($b, 0x08)
        $values = [BitConverter]::ToInt32($b, 0x0C)
        $count = [BitConverter]::ToInt32($b, 0x10)
        for ($i = 0; $i -lt $count; $i++) {
            $e = 0x14 + $i * 16
            $at = $keys + [BitConverter]::ToUInt16($b, $e)
            $end = $at
            while ($end -lt $b.Length -and $b[$end] -ne 0) { $end++ }
            if ([Text.Encoding]::ASCII.GetString($b, $at, $end - $at) -cne 'APP_VER') { continue }
            $text = [Text.Encoding]::UTF8.GetString($b, $values + [BitConverter]::ToInt32($b, $e + 12), [BitConverter]::ToInt32($b, $e + 4))
            return $text.TrimEnd([char]0).Trim()
        }
    } catch { }
    return ''
}

# =============================================================================
#  BBPort's own menu texts
#  Some BBPort features add texts to every language's menu (Quit to Desktop,
#  Rebirth at the Doll), in layers that BBPort writes at each start below the
#  mods. The Spanish menu of this pack has to carry them too.
# =============================================================================

# Whether a BBPort feature that adds menu texts is on, as BBPort decides at
# each start: this BBPort has its script (scripts\<script>), bbport.ini doesn't
# set <key>=0, and the game is version 1.09 (or its version can't be read).
function Test-PortFeature([string]$port, [string]$game, [string]$script, [string]$key) {
    if (-not [IO.File]::Exists([IO.Path]::Combine($port, 'scripts', $script))) { return $false }
    $ini = [IO.Path]::Combine((Get-PortDataFolder $port), 'bbport.ini')
    if ($env:BB_CONFIG -and $env:BB_CONFIG.Trim()) { $ini = $env:BB_CONFIG.Trim() }
    try {
        if ([IO.File]::Exists($ini)) {
            foreach ($line in [IO.File]::ReadAllLines($ini)) {
                if ($line.Trim() -cmatch ('^' + [regex]::Escape($key) + '=(.*)$')) {
                    if ($Matches[1] -eq '0') { return $false }
                    break
                }
            }
        }
    } catch { }
    $version = Get-GameVersion $game
    return (-not $version -or $version -eq '01.09')
}

# Quit to Desktop's Spanish texts and where they go (Fmg = text table: 200
# entries, 201 help line, 204 dialogs; Id = entry), read from this BBPort's
# scripts\quit_menu.py: the System menu's entry moved from 110005 to 110006 in
# BBPort 1.9.3. Empty if that file isn't there or its ids can't be read.
function Get-PortQuitTexts([string]$port) {
    try {
        $code = [IO.File]::ReadAllText([IO.Path]::Combine($port, 'scripts', 'quit_menu.py'))
    } catch {
        return @()
    }
    $ids = [regex]::Match($code, '(?m)^\s*TITLE_ID\s*,\s*SYSTEM_ID\s*,\s*DIALOG_ID\s*=\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)')
    if (-not $ids.Success) { return @() }
    $title = [int]$ids.Groups[1].Value
    $system = [int]$ids.Groups[2].Value
    $dialog = [int]$ids.Groups[3].Value
    $words = @('Salir al escritorio', 'Cerrar el juego.', 'Guardar y cerrar el juego.', '¿Salir del juego y volver al escritorio?')
    $found = [regex]::Match($code, "'spaes'\s*:\s*\(\s*'([^']*)'\s*,\s*'([^']*)'\s*,\s*'([^']*)'\s*,\s*'([^']*)'\s*\)")
    if ($found.Success) { $words = @($found.Groups[1].Value, $found.Groups[2].Value, $found.Groups[3].Value, $found.Groups[4].Value) }
    return @(
        [pscustomobject]@{ Fmg = 200; Id = $title;  Text = $words[0] },
        [pscustomobject]@{ Fmg = 200; Id = $system; Text = $words[0] },
        [pscustomobject]@{ Fmg = 201; Id = $title;  Text = $words[1] },
        [pscustomobject]@{ Fmg = 201; Id = $system; Text = $words[2] },
        [pscustomobject]@{ Fmg = 204; Id = $dialog; Text = $words[3] }
    )
}

# Where Rebirth at the Doll (BBPort 1.9.4) puts its choice's name (Fmg, Id),
# read from this BBPort's scripts\rebirth.py, or $null.
function Get-PortRebirthText([string]$port) {
    try {
        $code = [IO.File]::ReadAllText([IO.Path]::Combine($port, 'scripts', 'rebirth.py'))
    } catch {
        return $null
    }
    $option = [regex]::Match($code, '(?m)^\s*OPTION_TEXT\s*,[^=\r\n]*=\s*(\d+)')
    $table = [regex]::Match($code, '(?m)^\s*TALK_FMG\s*=\s*(\d+)')
    if (-not $option.Success -or -not $table.Success) { return $null }
    return [pscustomobject]@{ Fmg = [int]$table.Groups[1].Value; Id = [int]$option.Groups[1].Value }
}

# The menu text archives of a language that BBPort wrote with the texts its
# features add (<data>\out\<layer>\dvdroot_ps4\msg\<language>\menu.msgbnd.dcx,
# written again each time the game starts), newest first; when the times are
# the same (coarse clocks on FAT drives) the bigger first, as each layer builds
# on the one before. BBPort's temporary game views (out\mod-game-*) are left out.
function Find-PortTextLayers([string]$data, [string]$language) {
    $out = [IO.Path]::Combine($data, 'out')
    if (-not [IO.Directory]::Exists($out)) { return @() }
    $found = @()
    foreach ($dir in [IO.Directory]::GetDirectories($out)) {
        if ([IO.Path]::GetFileName($dir) -like 'mod-game-*') { continue }
        $file = [IO.Path]::Combine($dir, 'dvdroot_ps4', 'msg', $language, 'menu.msgbnd.dcx')
        if (-not [IO.File]::Exists($file)) { continue }
        $info = New-Object IO.FileInfo($file)
        $found += [pscustomobject]@{ Path = $file; Time = $info.LastWriteTimeUtc; Size = $info.Length }
    }
    return @($found | Sort-Object -Property @{ Expression = 'Time'; Descending = $true }, @{ Expression = 'Size'; Descending = $true } | ForEach-Object { $_.Path })
}

# Text of a TOML "basic string" (backslash escapes).
function ConvertFrom-TomlString([string]$text) {
    $out = New-Object System.Text.StringBuilder
    $i = 0
    while ($i -lt $text.Length) {
        $c = $text[$i]
        if ($c -ne [char]'\' -or ($i + 1) -ge $text.Length) {
            [void]$out.Append($c)
            $i++
            continue
        }
        $e = [string]$text[$i + 1]
        if ($e -ceq 'u' -and ($i + 6) -le $text.Length) {
            [void]$out.Append([char][Convert]::ToInt32($text.Substring($i + 2, 4), 16))
            $i += 6
        } elseif ($e -ceq 'U' -and ($i + 10) -le $text.Length) {
            [void]$out.Append([char]::ConvertFromUtf32([Convert]::ToInt32($text.Substring($i + 2, 8), 16)))
            $i += 10
        } else {
            if     ($e -ceq 'b') { [void]$out.Append([char]8) }
            elseif ($e -ceq 't') { [void]$out.Append([char]9) }
            elseif ($e -ceq 'n') { [void]$out.Append([char]10) }
            elseif ($e -ceq 'f') { [void]$out.Append([char]12) }
            elseif ($e -ceq 'r') { [void]$out.Append([char]13) }
            else { [void]$out.Append($e) }
            $i += 2
        }
    }
    return $out.ToString()
}

# The game folder set in BBLauncher (installPath in LauncherSettings.toml), or ''.
function Get-LauncherGamePath([string]$launcher) {
    $file = [IO.Path]::Combine($launcher, 'LauncherSettings.toml')
    if (-not [IO.File]::Exists($file)) { return '' }
    $table = ''
    foreach ($line in [IO.File]::ReadAllLines($file)) {
        $t = $line.Trim()
        if ($t.StartsWith('[')) { $table = $t.Trim('[', ']', ' ', '"'); continue }
        if ($table -ne 'Launcher') { continue }
        if ($t -match '^installPath\s*=\s*"((?:[^"\\]|\\.)*)"') { return (ConvertFrom-TomlString $Matches[1]) }
        if ($t -match "^installPath\s*=\s*'([^']*)'") { return $Matches[1] }
    }
    return ''
}

# Accepts the game folder or something close to it (dvdroot_ps4, the -UPDATE,
# -patch or -mods folder, a .zar path, or a folder holding one CUSA folder).
# Returns the base game folder (the one with dvdroot_ps4), or '' and sets
# $script:GameProblem to 'zar' or 'missing'.
function Resolve-GameFolder([string]$selected) {
    $script:GameProblem = 'missing'
    if ([string]::IsNullOrWhiteSpace($selected)) { return '' }
    $path = $selected.Trim().Trim('"')
    if ($path.Length -gt 3) { $path = $path.TrimEnd('\', '/') }
    if ($path.EndsWith('.zar', [StringComparison]::OrdinalIgnoreCase)) { $path = $path.Substring(0, $path.Length - 4) }
    if ([IO.Path]::GetFileName($path) -ieq 'dvdroot_ps4') { $path = [IO.Path]::GetDirectoryName($path) }
    foreach ($suffix in @('-UPDATE', '-patch', '-mods')) {
        if ($path.EndsWith($suffix, [StringComparison]::OrdinalIgnoreCase)) {
            $path = $path.Substring(0, $path.Length - $suffix.Length)
        }
    }
    if (-not [IO.Directory]::Exists([IO.Path]::Combine($path, 'dvdroot_ps4')) -and [IO.Directory]::Exists($path)) {
        $children = @([IO.Directory]::GetDirectories($path) | Where-Object {
            ([IO.Path]::GetFileName($_) -match '^CUSA\d{5}$') -and [IO.Directory]::Exists([IO.Path]::Combine($_, 'dvdroot_ps4'))
        })
        if ($children.Count -eq 1) { $path = $children[0] }
    }
    if ([IO.Directory]::Exists([IO.Path]::Combine($path, 'dvdroot_ps4'))) {
        $script:GameProblem = ''
        return $path
    }
    if ([IO.File]::Exists($path + '.zar')) { $script:GameProblem = 'zar' }
    return ''
}

function Show-GameProblem([string]$path) {
    if ($script:GameProblem -eq 'zar') {
        Say (T 'Ese juego está en un archivo .zar (comprimido). Este instalador necesita el juego como carpeta normal (la carpeta CUSA03173 de tu dump).' `
               'That game is stored as a .zar archive. This installer needs the game as a regular folder (the CUSA03173 folder from your dump).') 'Yellow'
    } else {
        Say ((T 'No encontré la carpeta dvdroot_ps4 en: {0}' "Couldn't find the dvdroot_ps4 folder in: {0}") -f $path) 'Yellow'
        Say (T 'Elige la carpeta CUSA03173 (la que tiene adentro dvdroot_ps4 y sce_sys).' `
               'Select the CUSA03173 folder (the one with dvdroot_ps4 and sce_sys inside).') 'Yellow'
    }
}

# Deletes a previous build of this pack before writing the new one. Only a
# folder that holds nothing but the pack's own folders counts: dvdroot_ps4
# as built, or msg, menu and sound as BBLauncher leaves it after Deactivate.
function Remove-OldBuild([string]$folder) {
    if (-not [IO.Directory]::Exists($folder)) { return $true }
    foreach ($entry in [IO.Directory]::GetFileSystemEntries($folder)) {
        $name = [IO.Path]::GetFileName($entry)
        if (@('dvdroot_ps4', 'msg', 'menu', 'sound') -notcontains $name -or -not [IO.Directory]::Exists($entry)) { return $false }
    }
    foreach ($file in [IO.Directory]::GetFiles($folder, '*', [IO.SearchOption]::AllDirectories)) {
        [IO.File]::SetAttributes($file, [IO.FileAttributes]::Normal)
    }
    [IO.Directory]::Delete($folder, $true)
    return $true
}

# =============================================================================
#  Game text archives: DCX (zlib) > BND4 > FMG.  Plain PowerShell, no add-ons.
# =============================================================================

function Read-UInt32BE([byte[]]$b, [int]$o) {
    return ([long]$b[$o] -shl 24) -bor ([long]$b[$o + 1] -shl 16) -bor ([long]$b[$o + 2] -shl 8) -bor [long]$b[$o + 3]
}

function Write-UInt32BE([byte[]]$b, [int]$o, [long]$v) {
    $b[$o]     = [byte](($v -shr 24) -band 0xFF)
    $b[$o + 1] = [byte](($v -shr 16) -band 0xFF)
    $b[$o + 2] = [byte](($v -shr 8) -band 0xFF)
    $b[$o + 3] = [byte]($v -band 0xFF)
}

function Write-Int32LE([byte[]]$b, [int]$o, [int]$v) { [Array]::Copy([BitConverter]::GetBytes($v), 0, $b, $o, 4) }
function Write-Int64LE([byte[]]$b, [int]$o, [long]$v) { [Array]::Copy([BitConverter]::GetBytes($v), 0, $b, $o, 8) }

# zlib checksum (Adler-32) of the uncompressed data
function Get-Adler32([byte[]]$data) {
    [long]$a = 1
    [long]$s = 0
    $n = $data.Length
    $i = 0
    while ($i -lt $n) {
        $end = [Math]::Min($i + 5552, $n)
        for (; $i -lt $end; $i++) { $a += $data[$i]; $s += $a }
        $a = $a % 65521
        $s = $s % 65521
    }
    return [long](($s -shl 16) -bor $a)
}

# Reads a .dcx file: returns its 0x4C-byte header and the unpacked contents.
function Read-Dcx([string]$path) {
    $file = [IO.File]::OpenRead($path)
    try {
        $start = New-Object byte[] 0x4E
        $got = 0
        while ($got -lt 0x4E) {
            $n = $file.Read($start, $got, 0x4E - $got)
            if ($n -le 0) { throw 'Not a DCX file.' }
            $got += $n
        }
        if ($start[0] -ne 0x44 -or $start[1] -ne 0x43 -or $start[2] -ne 0x58 -or $start[3] -ne 0) { throw 'Not a DCX file.' }
        if ($start[0x28] -ne 0x44 -or $start[0x29] -ne 0x46 -or $start[0x2A] -ne 0x4C -or $start[0x2B] -ne 0x54) { throw 'Unsupported DCX compression.' }
        $unc = [int](Read-UInt32BE $start 0x1C)
        $comp = [long](Read-UInt32BE $start 0x20)
        if ($comp -lt 6 -or (0x4C + $comp) -gt $file.Length) { throw 'Truncated DCX file.' }
        $header = New-Object byte[] 0x4C
        [Array]::Copy($start, $header, 0x4C)
        $raw = New-Object byte[] $unc
        $inflate = New-Object IO.Compression.DeflateStream($file, [IO.Compression.CompressionMode]::Decompress, $true)
        $read = 0
        try {
            while ($read -lt $unc) {
                $n = $inflate.Read($raw, $read, $unc - $read)
                if ($n -le 0) { break }
                $read += $n
            }
        } finally {
            $inflate.Dispose()
        }
        if ($read -ne $unc) { throw 'DCX size mismatch.' }
        return @{ Header = $header; Raw = $raw }
    } finally {
        $file.Dispose()
    }
}

# Writes a .dcx file with the given header and contents.
function Write-Dcx([string]$path, [byte[]]$header, [byte[]]$raw) {
    $file = [IO.File]::Create($path)
    try {
        $start = New-Object byte[] 0x4E
        [Array]::Copy($header, $start, 0x4C)
        $start[0x4C] = 0x78
        $start[0x4D] = 0xDA
        $file.Write($start, 0, 0x4E)
        $deflate = New-Object IO.Compression.DeflateStream($file, [IO.Compression.CompressionLevel]::Optimal, $true)
        try {
            $deflate.Write($raw, 0, $raw.Length)
        } finally {
            $deflate.Dispose()
        }
        $tail = New-Object byte[] 4
        Write-UInt32BE $tail 0 (Get-Adler32 $raw)
        $file.Write($tail, 0, 4)
        Write-UInt32BE $start 0x1C $raw.Length
        Write-UInt32BE $start 0x20 ($file.Length - 0x4C)
        $file.Position = 0
        $file.Write($start, 0, 0x4C)
    } finally {
        $file.Dispose()
    }
}

function Read-Bnd4([byte[]]$b) {
    if ($b.Length -lt 0x40 -or $b[0] -ne 0x42 -or $b[1] -ne 0x4E -or $b[2] -ne 0x44 -or $b[3] -ne 0x34) { throw 'Not a BND4 archive.' }
    $count = [BitConverter]::ToInt32($b, 0x0C)
    $fileHeaderSize = [BitConverter]::ToInt64($b, 0x20)
    $headersEnd = [int][BitConverter]::ToInt64($b, 0x28)
    if ($fileHeaderSize -ne 0x24 -or $b[0x30] -ne 1 -or $b[0x31] -ne 0x74 -or $b[0x32] -ne 0) { throw 'Unexpected BND4 layout.' }
    $files = New-Object System.Collections.ArrayList
    for ($i = 0; $i -lt $count; $i++) {
        $o = 0x40 + $i * 0x24
        $size = [int][BitConverter]::ToInt64($b, $o + 8)
        $offset = [BitConverter]::ToInt32($b, $o + 24)
        $data = New-Object byte[] $size
        [Array]::Copy($b, $offset, $data, 0, $size)
        [void]$files.Add([pscustomobject]@{
            Flags      = $b[$o]
            Id         = [BitConverter]::ToInt32($b, $o + 28)
            NameOffset = [BitConverter]::ToInt32($b, $o + 32)
            Data       = $data
        })
    }
    return @{ Files = $files; HeadersEnd = $headersEnd }
}

function Write-Bnd4([byte[]]$original, [int]$headersEnd, $files) {
    $total = $headersEnd
    $offsets = New-Object int[] $files.Count
    for ($i = 0; $i -lt $files.Count; $i++) {
        $total = ($total + 15) -band (-bnot 15)
        $offsets[$i] = $total
        $total += $files[$i].Data.Length
    }
    $result = New-Object byte[] $total
    [Array]::Copy($original, $result, $headersEnd)
    for ($i = 0; $i -lt $files.Count; $i++) {
        $o = 0x40 + $i * 0x24
        $f = $files[$i]
        $result[$o] = $f.Flags
        $result[$o + 1] = 0
        $result[$o + 2] = 0
        $result[$o + 3] = 0
        Write-Int32LE $result ($o + 4) (-1)
        Write-Int64LE $result ($o + 8) $f.Data.Length
        Write-Int64LE $result ($o + 16) $f.Data.Length
        Write-Int32LE $result ($o + 24) $offsets[$i]
        Write-Int32LE $result ($o + 28) $f.Id
        Write-Int32LE $result ($o + 32) $f.NameOffset
        [Array]::Copy($f.Data, 0, $result, $offsets[$i], $f.Data.Length)
    }
    return ,$result
}

function Read-Fmg([byte[]]$b) {
    if ($b.Length -lt 0x28 -or $b[0] -ne 0 -or $b[1] -ne 0 -or $b[2] -ne 2 -or $b[3] -ne 0) { throw 'Unexpected FMG format.' }
    $groupCount = [BitConverter]::ToInt32($b, 0x0C)
    $stringCount = [BitConverter]::ToInt32($b, 0x10)
    $stringOffsets = [int][BitConverter]::ToInt64($b, 0x18)
    $unk08 = New-Object byte[] 4
    [Array]::Copy($b, 8, $unk08, 0, 4)
    $ids = New-Object System.Collections.ArrayList
    $strings = New-Object System.Collections.ArrayList
    $end = $stringOffsets + $stringCount * 8
    for ($g = 0; $g -lt $groupCount; $g++) {
        $go = 0x28 + $g * 16
        $index = [BitConverter]::ToInt32($b, $go)
        $first = [BitConverter]::ToInt32($b, $go + 4)
        $last = [BitConverter]::ToInt32($b, $go + 8)
        for ($id = $first; $id -le $last; $id++) {
            $p = [int][BitConverter]::ToInt64($b, $stringOffsets + ($index + $id - $first) * 8)
            $s = $null
            if ($p -ne 0) {
                $e = $p
                while (($e + 1) -lt $b.Length -and ($b[$e] -ne 0 -or $b[$e + 1] -ne 0)) { $e += 2 }
                if (($e + 1) -ge $b.Length) { throw 'Unexpected FMG format.' }
                $s = [Text.Encoding]::Unicode.GetString($b, $p, $e - $p)
                if ($e + 2 -gt $end) { $end = $e + 2 }
            }
            [void]$ids.Add([int]$id)
            [void]$strings.Add($s)
        }
    }
    return @{ Ids = $ids; Strings = $strings; TailPad = [Math]::Max(0, $b.Length - $end); Unk08 = $unk08 }
}

function Write-Fmg($fmg) {
    $ids = $fmg.Ids
    $strings = $fmg.Strings
    $groups = New-Object System.Collections.ArrayList
    for ($k = 0; $k -lt $ids.Count; $k++) {
        if ($groups.Count -gt 0 -and $ids[$k] -eq ($groups[$groups.Count - 1][1] + 1)) {
            $groups[$groups.Count - 1][1] = $ids[$k]
        } else {
            [void]$groups.Add([int[]]@($ids[$k], $ids[$k]))
        }
    }
    $stringOffsets = 0x28 + 16 * $groups.Count
    $size = $stringOffsets + 8 * $ids.Count
    $encoded = New-Object object[] $ids.Count
    for ($k = 0; $k -lt $ids.Count; $k++) {
        if ($null -ne $strings[$k]) {
            $encoded[$k] = [Text.Encoding]::Unicode.GetBytes([string]$strings[$k])
            $size += $encoded[$k].Length + 2
        }
    }
    $size += $fmg.TailPad
    $b = New-Object byte[] $size
    $b[2] = 2
    Write-Int32LE $b 4 $size
    [Array]::Copy($fmg.Unk08, 0, $b, 8, 4)
    Write-Int32LE $b 0x0C $groups.Count
    Write-Int32LE $b 0x10 $ids.Count
    Write-Int32LE $b 0x14 0xFF
    Write-Int64LE $b 0x18 $stringOffsets
    $index = 0
    for ($g = 0; $g -lt $groups.Count; $g++) {
        $go = 0x28 + $g * 16
        Write-Int32LE $b $go $index
        Write-Int32LE $b ($go + 4) $groups[$g][0]
        Write-Int32LE $b ($go + 8) $groups[$g][1]
        $index += $groups[$g][1] - $groups[$g][0] + 1
    }
    $pos = $stringOffsets + 8 * $ids.Count
    for ($k = 0; $k -lt $ids.Count; $k++) {
        if ($null -eq $encoded[$k]) { continue }
        Write-Int64LE $b ($stringOffsets + $k * 8) $pos
        [Array]::Copy($encoded[$k], 0, $b, $pos, $encoded[$k].Length)
        $pos += $encoded[$k].Length + 2
    }
    return ,$b
}

# The text of entry $id in a text table read with Read-Fmg, or $null.
function Get-FmgText($fmg, [int]$id) {
    $at = $fmg.Ids.IndexOf($id)
    if ($at -lt 0) { return $null }
    return $fmg.Strings[$at]
}

# Whether a menu text archive BBPort wrote fits this BBPort and its settings
# now: written after BBPort's scripts were last updated, and with Quit to
# Desktop's and Rebirth's texts exactly when those features are on. If not,
# it is from another version of BBPort or from before its options changed.
function Test-PortTextLayer([string]$file, [string]$port, [bool]$quitOn, $quitTexts, [bool]$rebirthOn, $rebirthText) {
    $scripts = [IO.Path]::Combine($port, 'scripts')
    if ([IO.Directory]::Exists($scripts)) {
        $written = [IO.File]::GetLastWriteTimeUtc($file)
        foreach ($script in [IO.Directory]::GetFiles($scripts, '*.py')) {
            if ([IO.File]::GetLastWriteTimeUtc($script) -gt $written) { return $false }
        }
    }
    $bnd = Read-Bnd4 (Read-Dcx $file).Raw
    $tables = @{}
    foreach ($f in $bnd.Files) { if (-not $tables.ContainsKey([int]$f.Id)) { $tables[[int]$f.Id] = $f } }
    if (@($quitTexts).Count -ge 2 -and $tables.ContainsKey(200)) {
        # Quit to Desktop's entries (title menu and System menu) have the same name
        $menu = Read-Fmg $tables[200].Data
        $titleName = Get-FmgText $menu $quitTexts[0].Id
        $hasQuit = [bool]$titleName -and ($titleName -ceq (Get-FmgText $menu $quitTexts[1].Id))
        if ($hasQuit -ne $quitOn) { return $false }
    }
    if ($rebirthText -and $tables.ContainsKey([int]$rebirthText.Fmg)) {
        $talk = Read-Fmg $tables[[int]$rebirthText.Fmg].Data
        $hasRebirth = [bool](Get-FmgText $talk $rebirthText.Id)
        if ($hasRebirth -ne $rebirthOn) { return $false }
    }
    return $true
}

# Copies menu.msgbnd.dcx from $source to $target, renaming language entries in
# its text table 200: entry copyTo[i] receives the text of entry copyFrom[i]
# (after the name fixes are applied). $texts (Fmg = text table, Id = entry,
# Text) are then set, adding the entry if the table doesn't have it.
function Update-MenuLabels([string]$source, [string]$target, [int[]]$copyTo, [int[]]$copyFrom, $fixes, $texts) {
    $dcxData = Read-Dcx $source
    $bnd = Read-Bnd4 $dcxData.Raw
    $tables = @{}
    foreach ($f in $bnd.Files) { if (-not $tables.ContainsKey([int]$f.Id)) { $tables[[int]$f.Id] = $f } }
    if (-not $tables.ContainsKey(200)) { throw 'Menu text table (200) not found.' }
    $fmgs = @{}
    foreach ($id in @(@(200) + @($texts | Where-Object { $null -ne $_ } | ForEach-Object { [int]$_.Fmg }) | Sort-Object -Unique)) {
        if ($tables.ContainsKey($id)) { $fmgs[$id] = Read-Fmg $tables[$id].Data }
    }
    $fmg = $fmgs[200]
    $index = @{}
    for ($k = 0; $k -lt $fmg.Ids.Count; $k++) { $index[[int]$fmg.Ids[$k]] = $k }
    foreach ($fix in $fixes) {
        if ($index.ContainsKey([int]$fix.Id) -and ($fmg.Strings[$index[[int]$fix.Id]] -ceq $fix.Old)) {
            $fmg.Strings[$index[[int]$fix.Id]] = $fix.New
        }
    }
    $values = New-Object object[] $copyTo.Length
    for ($i = 0; $i -lt $copyTo.Length; $i++) {
        if ($index.ContainsKey($copyFrom[$i])) { $values[$i] = $fmg.Strings[$index[$copyFrom[$i]]] }
    }
    for ($i = 0; $i -lt $copyTo.Length; $i++) {
        if ($null -ne $values[$i] -and $index.ContainsKey($copyTo[$i])) { $fmg.Strings[$index[$copyTo[$i]]] = $values[$i] }
    }
    foreach ($t in @($texts)) {
        if ($null -eq $t -or -not $fmgs.ContainsKey([int]$t.Fmg)) { continue }
        $table = $fmgs[[int]$t.Fmg]
        $at = $table.Ids.IndexOf([int]$t.Id)
        if ($at -ge 0) {
            $table.Strings[$at] = $t.Text
        } else {
            # Entries stay sorted by id
            $at = 0
            while ($at -lt $table.Ids.Count -and [int]$table.Ids[$at] -lt [int]$t.Id) { $at++ }
            $table.Ids.Insert($at, [int]$t.Id)
            $table.Strings.Insert($at, [string]$t.Text)
        }
    }
    foreach ($id in $fmgs.Keys) { $tables[$id].Data = Write-Fmg $fmgs[$id] }
    $rebuilt = Write-Bnd4 $dcxData.Raw $bnd.HeadersEnd $bnd.Files
    Write-Dcx $target $dcxData.Header $rebuilt
}

# =============================================================================
#  Main
# =============================================================================

function Invoke-Main {
    if ($PSScriptRoot) { $here = $PSScriptRoot } else { $here = (Get-Location).Path }

    Say ''
    Say ('=== {0} v{1} - by {2} (Game Developer) ===' -f $script:ModName, $script:ModVersion, $script:Author) 'Cyan'
    Say (T 'Idiomas de América para Bloodborne GOTY, sin "Unlock Game Region" (el online sigue funcionando).' `
           'Languages of the Americas for Bloodborne GOTY, without "Unlock Game Region" (online keeps working).') 'Cyan'
    Say (T 'Tu juego no se modifica: se crea un mod aparte.' 'Your game is not modified: a separate mod is created.') 'Cyan'
    Say ''

    # 1. BBLauncher or BBPort: next to this installer (or a few folders above
    #    it), or ask. If both are found, the one closer to the installer wins.
    $launcher = Find-Launcher $here 4
    $port = Find-Port $here 4
    if ($launcher -and $port) {
        if ($port.Length -ge [IO.Path]::GetDirectoryName($launcher).Length) { $launcher = '' } else { $port = '' }
    }
    if (-not $launcher -and -not $port -and -not $GameFolder) {
        Say (T 'No encontré BBLauncher ni BBPort junto a este instalador.' "BBLauncher or BBPort wasn't found next to this installer.") 'Yellow'
        while ($true) {
            $picked = Select-Folder (T 'Elige tu carpeta de BBLauncher (la que tiene BB_Launcher.exe) o de BBPort (la que tiene Bloodborne.exe). Si no usas ninguno, da clic en Cancelar.' `
                                       'Select your BBLauncher folder (the one with BB_Launcher.exe) or your BBPort folder (the one with Bloodborne.exe). If you use neither, click Cancel.') ([IO.Path]::GetDirectoryName($here))
            if ([string]::IsNullOrWhiteSpace($picked)) { break }
            $picked = $picked.Trim().Trim('"')
            $launcher = Find-Launcher $picked 2
            if (-not $launcher) { $port = Find-Port $picked 2 }
            if ($launcher -or $port) { break }
            Say ((T 'En esa carpeta no está BB_Launcher.exe ni Bloodborne.exe: {0}' "Neither BB_Launcher.exe nor Bloodborne.exe is in that folder: {0}") -f $picked) 'Yellow'
        }
    }
    $portSettings = $null
    if ($port) { $portSettings = Get-PortSettings }
    if ($launcher) {
        Say ((T 'BBLauncher: {0}' 'BBLauncher: {0}') -f [IO.Path]::GetDirectoryName($launcher))
        # Rebuilding the pack while BBLauncher has it active would mix old and new files
        if ([IO.Directory]::Exists([IO.Path]::Combine($launcher, $script:ActiveName, $script:ModName))) {
            Say ''
            Say ((T 'El pack está activo en BBLauncher. Primero desactívalo (Mod Manager > Active Mods > "{0}" > Deactivate Mod) y luego vuelve a correr el instalador.' `
                    'The pack is active in BBLauncher. Deactivate it first (Mod Manager > Active Mods > "{0}" > Deactivate Mod), then run the installer again.') -f $script:ModName) 'Yellow'
            return
        }
    } elseif ($port) {
        Say ((T 'BBPort: {0}' 'BBPort: {0}') -f $port)
    } else {
        Say (T 'Sin BBLauncher ni BBPort: el mod se creará junto a este instalador.' 'Without BBLauncher or BBPort: the mod will be created next to this installer.')
    }

    # 2. Game folder: -GameFolder, else the one set in BBLauncher or BBPort, else ask
    $base = ''
    if ($GameFolder) {
        $base = Resolve-GameFolder $GameFolder
        if (-not $base) { Show-GameProblem $GameFolder; return }
    } elseif ($launcher) {
        $fromLauncher = Get-LauncherGamePath $launcher
        if ($fromLauncher) {
            $base = Resolve-GameFolder $fromLauncher
            if (-not $base) {
                Say ((T 'BBLauncher tiene este juego: {0}' 'BBLauncher has this game set: {0}') -f $fromLauncher) 'Yellow'
                Show-GameProblem $fromLauncher
            }
        }
    } elseif ($port) {
        $fromPort = Get-PortGamePath $port $portSettings
        $base = Resolve-GameFolder $fromPort
        if (-not $base -and $portSettings -and $portSettings.game_dir) {
            Say ((T 'BBPort tiene este juego: {0}' 'BBPort has this game set: {0}') -f $fromPort) 'Yellow'
            Show-GameProblem $fromPort
        }
    }
    while (-not $base) {
        if ($launcher) {
            $startAt = [IO.Path]::GetDirectoryName([IO.Path]::GetDirectoryName($launcher))
        } elseif ($port) {
            $startAt = [IO.Path]::GetDirectoryName($port)
        } else {
            $startAt = [IO.Path]::GetDirectoryName($here)
        }
        $picked = Select-Folder (T 'Elige la carpeta del juego (la que se llama CUSA03173)' 'Select your game folder (the one named CUSA03173)') $startAt
        if ([string]::IsNullOrWhiteSpace($picked)) {
            Say (T 'No elegiste ninguna carpeta. No se hizo nada.' 'No folder selected. Nothing was done.') 'Yellow'
            return
        }
        $base = Resolve-GameFolder $picked
        if (-not $base) { Show-GameProblem $picked }
    }
    Say ((T 'Juego: {0}' 'Game: {0}') -f $base)

    # 3. Separate update folder, if any (same order shadPS4 uses)
    $update = $null
    foreach ($suffix in @('-UPDATE', '-patch')) {
        $candidate = $base + $suffix
        if ([IO.Directory]::Exists([IO.Path]::Combine($candidate, 'dvdroot_ps4'))) { $update = $candidate; break }
    }
    if (-not $update) {
        foreach ($suffix in @('-UPDATE', '-patch')) {
            if ([IO.File]::Exists($base + $suffix + '.zar')) {
                Say ((T 'Tu update está en un archivo .zar ({0}). Este instalador necesita el update como carpeta normal, o el juego ya actualizado.' `
                        'Your update is stored as a .zar archive ({0}). This installer needs the update as a regular folder, or the game already updated.') -f [IO.Path]::GetFileName($base + $suffix + '.zar')) 'Red'
                return
            }
        }
    }

    # Returns the file the game actually loads: update first, then base game
    function Find-GameFile([string[]]$parts) {
        $relative = [IO.Path]::Combine([string[]]$parts)
        if ($update) {
            $path = [IO.Path]::Combine($update, $relative)
            if ([IO.File]::Exists($path)) { return $path }
        }
        $path = [IO.Path]::Combine($base, $relative)
        if ([IO.File]::Exists($path)) { return $path }
        return $null
    }

    function Find-VoiceFiles([string]$suffix) {
        $names = @{}
        foreach ($root in @($update, $base)) {
            if (-not $root) { continue }
            $folder = [IO.Path]::Combine($root, 'dvdroot_ps4', 'sound')
            if ([IO.Directory]::Exists($folder)) {
                foreach ($file in [IO.Directory]::GetFiles($folder, '*_' + $suffix + '.fsb')) {
                    $name = [IO.Path]::GetFileName($file)
                    if ($name -match ('_' + $suffix + '\.fsb$')) { $names[$name.ToLowerInvariant()] = $name }
                }
            }
        }
        $result = @()
        foreach ($name in ($names.Values | Sort-Object)) {
            $source = Find-GameFile @('dvdroot_ps4', 'sound', $name)
            if ($source) { $result += $source }
        }
        return ,$result
    }

    # 4. Which languages can be added with this copy of the game
    #    (BBPort: only the Latin American Spanish text, see $script:PortPack)
    $packs = $script:Packs
    if ($port) { $packs = @($script:PortPack) }
    $included = @()
    foreach ($pack in $packs) {
        $name = T $pack.Es $pack.En
        $item = Find-GameFile @('dvdroot_ps4', 'msg', $pack.Text, 'item.msgbnd.dcx')
        $menu = Find-GameFile @('dvdroot_ps4', 'msg', $pack.Text, 'menu.msgbnd.dcx')
        $slotMenu = Find-GameFile @('dvdroot_ps4', 'msg', $pack.Slot, 'menu.msgbnd.dcx')
        if (-not $item -or -not $menu -or -not $slotMenu) {
            Say ((T '  - {0}: no viene en tu copia, se omite.' '  - {0}: not found in your copy, skipped.') -f $name) 'Yellow'
            continue
        }
        $voices = @()
        if ($pack.Voice) {
            $voices = Find-VoiceFiles $pack.Voice
            if ($voices.Count -eq 0) {
                Say ((T '  - {0}: no encontré sus voces, se omite.' "  - {0}: its voice files weren't found, skipped.") -f $name) 'Yellow'
                continue
            }
        }
        $included += [pscustomobject]@{ Pack = $pack; Item = $item; Voices = $voices }
    }
    if ($included.Count -eq 0) {
        Say (T 'No encontré ninguno de los idiomas en esta carpeta. ¿Es la carpeta de Bloodborne? No se hizo nada.' `
               'None of the languages were found in this folder. Is this the Bloodborne folder? Nothing was done.') 'Red'
        return
    }

    # 5. Plan: plain copies (text, fonts, voices) and renamed menus
    $copies = New-Object System.Collections.Generic.List[object]
    foreach ($entry in $included) {
        $pack = $entry.Pack
        $copies.Add([pscustomobject]@{ Source = $entry.Item; Target = [IO.Path]::Combine('dvdroot_ps4', 'msg', $pack.Slot, 'item.msgbnd.dcx') })
        $font = Find-GameFile @('dvdroot_ps4', 'menu', $pack.Text, 'font.gfx')
        if ($font) { $copies.Add([pscustomobject]@{ Source = $font; Target = [IO.Path]::Combine('dvdroot_ps4', 'menu', $pack.Slot, 'font.gfx') }) }
        foreach ($voice in $entry.Voices) {
            $targetName = [IO.Path]::GetFileName($voice) -replace ('_' + $pack.Voice + '\.fsb$'), ('_' + $pack.SlotVoice + '.fsb')
            $copies.Add([pscustomobject]@{ Source = $voice; Target = [IO.Path]::Combine('dvdroot_ps4', 'sound', $targetName) })
        }
    }

    $copyTo = [int[]]@($included | ForEach-Object { $_.Pack.LabelSlot })
    $copyFrom = [int[]]@($included | ForEach-Object { $_.Pack.Label })
    $menus = New-Object System.Collections.Generic.List[object]
    $portLayer = ''
    $portTexts = $false
    $portNote = $false
    if ($port) {
        # BBPort: the Latin American menu with the texts BBPort's features add to
        # it. BBPort's own copy (written when the game last started) if it fits
        # this BBPort and its settings; else the game's, with Quit to Desktop's.
        $quitOn = Test-PortFeature $port $base 'quit_menu.py' 'quit_to_desktop'
        $rebirthOn = Test-PortFeature $port $base 'rebirth.py' 'rebirth'
        $quitTexts = @(Get-PortQuitTexts $port)
        $rebirthText = Get-PortRebirthText $port
        $layers = @()
        try { $layers = @(Find-PortTextLayers (Get-PortDataFolder $port) $script:PortPack.Text) } catch { $layers = @() }
        foreach ($layer in $layers) {
            try { $fits = Test-PortTextLayer $layer $port $quitOn $quitTexts $rebirthOn $rebirthText } catch { $fits = $false }
            if ($fits) {
                $portLayer = $layer
                break
            }
        }
        $texts = @()
        if ($portLayer) {
            $portTexts = $quitOn -or $rebirthOn
        } else {
            if ($quitOn) { $texts = $quitTexts }
            $portTexts = $texts.Count -gt 0
            $portNote = $rebirthOn -or ($quitOn -and $texts.Count -eq 0)
        }
        foreach ($entry in $included) {
            $menuSource = $portLayer
            if (-not $menuSource) { $menuSource = Find-GameFile @('dvdroot_ps4', 'msg', $entry.Pack.Text, 'menu.msgbnd.dcx') }
            $menus.Add([pscustomobject]@{ Source = $menuSource; SourceLang = $entry.Pack.Text; Slot = $entry.Pack.Slot; Texts = $texts; Target = [IO.Path]::Combine('dvdroot_ps4', 'msg', $entry.Pack.Slot, 'menu.msgbnd.dcx') })
        }
    } else {
        foreach ($slot in $script:EuSlots) {
            if (-not (Find-GameFile @('dvdroot_ps4', 'msg', $slot, 'menu.msgbnd.dcx'))) { continue }
            $sourceLang = $slot
            foreach ($entry in $included) { if ($entry.Pack.Slot -eq $slot) { $sourceLang = $entry.Pack.Text } }
            $source = Find-GameFile @('dvdroot_ps4', 'msg', $sourceLang, 'menu.msgbnd.dcx')
            if (-not $source) { continue }
            $menus.Add([pscustomobject]@{ Source = $source; SourceLang = $sourceLang; Slot = $slot; Texts = @(); Target = [IO.Path]::Combine('dvdroot_ps4', 'msg', $slot, 'menu.msgbnd.dcx') })
        }
    }

    # 6. Where the mod is created: BBLauncher\Mods, BBPort's mods folder, or next to this installer
    $portMods = ''
    if ($launcher) {
        $output = [IO.Path]::Combine($launcher, 'Mods', $script:ModName)
    } elseif ($port) {
        $portMods = Get-PortModsFolder $port $portSettings
        $output = [IO.Path]::Combine($portMods, $script:ModName)
    } else {
        $output = [IO.Path]::Combine($here, $script:ModName)
    }

    $totalBytes = [long]0
    foreach ($c in $copies) { $totalBytes += (New-Object IO.FileInfo($c.Source)).Length }
    foreach ($m in $menus) { $totalBytes += 2 * (New-Object IO.FileInfo($m.Source)).Length }
    try {
        $freeBytes = (New-Object IO.DriveInfo([IO.Path]::GetPathRoot($output))).AvailableFreeSpace
        if ($freeBytes -lt ($totalBytes + 200MB)) {
            Say ((T 'No hay espacio suficiente: se necesitan {0:N1} GB y hay {1:N1} GB libres en ese disco.' `
                    'Not enough disk space: {0:N1} GB needed, {1:N1} GB free on that drive.') -f (($totalBytes + 200MB) / 1GB), ($freeBytes / 1GB)) 'Red'
            return
        }
    } catch { }

    if (-not (Remove-OldBuild $output)) {
        Say ((T 'Ya existe la carpeta "{0}" y tiene otros archivos. Muévela a otro lado y vuelve a correr el instalador.' `
                'The folder "{0}" already exists and has other files in it. Move it somewhere else and run the installer again.') -f $output) 'Red'
        return
    }
    $script:Building = $output

    # 7. Copy text, fonts and voices
    $steps = $copies.Count + $menus.Count
    Say ''
    if ($totalBytes -ge 1GB) { $size = '{0:N1} GB' -f ($totalBytes / 1GB) } else { $size = '{0:N0} MB' -f [Math]::Max(1, [Math]::Ceiling($totalBytes / 1MB)) }
    Say ((T 'Creando el mod ({0} archivos, {1}). Puede tardar unos minutos...' 'Building the mod ({0} files, {1}). This can take a few minutes...') -f $steps, $size)
    $activity = T 'Creando Americas Language Pack' 'Building Americas Language Pack'
    $i = 0
    foreach ($c in $copies) {
        $i++
        $target = [IO.Path]::Combine($output, $c.Target)
        [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($target))
        Write-Progress -Activity $activity -Status ('{0} / {1}: {2}' -f $i, $steps, [IO.Path]::GetFileName($target)) -PercentComplete ([int](100 * $i / $steps))
        [IO.File]::Copy($c.Source, $target, $true)
        [IO.File]::SetAttributes($target, [IO.FileAttributes]::Normal)
    }

    # 8. Menus: the language entries renamed in every European text language
    #    (BBPort: the Spanish menu with its Quit to Desktop texts)
    foreach ($m in $menus) {
        $i++
        $target = [IO.Path]::Combine($output, $m.Target)
        [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($target))
        Write-Progress -Activity $activity -Status ((T '{0} / {1}: textos del menú ({2})' '{0} / {1}: menu texts ({2})') -f $i, $steps, $m.Slot) -PercentComplete ([int](100 * $i / $steps))
        $fixes = @($script:Fixes | Where-Object { $_.Source -eq $m.SourceLang })
        Update-MenuLabels $m.Source $target $copyTo $copyFrom $fixes $m.Texts
    }
    Write-Progress -Activity $activity -Completed
    $script:Building = $null

    # 9. Summary
    Say ''
    Say (T 'LISTO.' 'DONE.') 'Green'
    Say ((T 'Mod creado en: {0}' 'Mod created at: {0}') -f $output) 'Green'
    Say ''
    Say (T 'Idiomas agregados:' 'Languages added:') 'Cyan'
    foreach ($entry in $included) {
        $pack = $entry.Pack
        if ($pack.Voice) {
            Say ((T '  + {0} (texto y {1} voces) - en el lugar de {2}' '  + {0} (text and {1} voice files) - in place of {2}') -f (T $pack.Es $pack.En), $entry.Voices.Count, (T $pack.OldEs $pack.OldEn))
        } else {
            Say ((T '  + {0} (texto) - en el lugar de {1}' '  + {0} (text) - in place of {1}') -f (T $pack.Es $pack.En), (T $pack.OldEs $pack.OldEn))
        }
    }
    if ($portTexts) { Say (T '  Con los textos que BBPort agrega al menú (como "Salir al escritorio").' '  With the texts BBPort adds to the menu (like "Quit to Desktop").') }
    if ($update) { Say ((T '  Usé primero los archivos de tu update ({0}).' '  Files from your update folder were used first ({0}).') -f [IO.Path]::GetFileName($update)) }

    if ($launcher) {
        $activeFolder = [IO.Path]::Combine($launcher, $script:ActiveName)
        if ([IO.Directory]::Exists($activeFolder)) {
            $others = @([IO.Directory]::GetDirectories($activeFolder) | Where-Object {
                ([IO.Path]::GetFileName($_) -ne $script:ModName) -and (
                    [IO.Directory]::Exists([IO.Path]::Combine($_, 'msg')) -or
                    @([IO.Directory]::GetFiles($_, '*.fsb', [IO.SearchOption]::AllDirectories)).Count -gt 0)
            } | ForEach-Object { [IO.Path]::GetFileName($_) })
            if ($others.Count -gt 0) {
                Say ''
                Say ((T 'OJO: tienes activo otro mod que también cambia textos o voces: {0}. Desactívalo antes de activar este.' `
                        'NOTE: another active mod also changes text or voices: {0}. Deactivate it before activating this one.') -f ($others -join ', ')) 'Yellow'
            }
        }
    }
    if ($port) {
        # Other mods that also change the Spanish (Spain) files: in BBPort the lower one in the list wins
        try {
            $others = @([IO.Directory]::GetDirectories($portMods) | Where-Object {
                ([IO.Path]::GetFileName($_) -ne $script:ModName) -and
                (@([IO.Directory]::GetDirectories($_, 'spaes', [IO.SearchOption]::AllDirectories)).Count -gt 0)
            } | ForEach-Object { [IO.Path]::GetFileName($_) })
            if ($others.Count -gt 0) {
                Say ''
                Say ((T 'OJO: en la carpeta mods de BBPort hay otro mod que también cambia el español: {0}. En Mods y parches (Mods & patches) gana el que está más abajo en la lista; si no ves el español latino, desmárcalo.' `
                        'NOTE: another mod in BBPort''s mods folder also changes Spanish: {0}. In Mods & patches the one lower in the list wins; if Latin American Spanish doesn''t show, untick it.') -f ($others -join ', ')) 'Yellow'
            }
        } catch { }
        # Mods turned off in BBPort's launcher, or this mod unticked in Mods & patches
        if ($portSettings -and ($portSettings.mods_enabled -eq $false)) {
            Say ''
            Say (T 'OJO: en BBPort está apagado "Cargar mods" (Load mods), en Mods y parches. Préndelo o el mod no se va a cargar.' `
                   'NOTE: "Load mods" is off in BBPort (Mods & patches). Turn it on or the mod won''t load.') 'Yellow'
        }
        try {
            $modListFile = [IO.Path]::Combine((Get-PortDataFolder $port), 'mods.json')
            if ([IO.File]::Exists($modListFile)) {
                $modList = [IO.File]::ReadAllText($modListFile) | ConvertFrom-Json
                if (@($modList.disabled) -contains $script:ModName) {
                    Say ''
                    Say ((T 'OJO: "{0}" está desmarcado en Mods y parches (Mods & patches) de BBPort. Márcalo para que se cargue.' `
                            'NOTE: "{0}" is unticked in BBPort''s Mods & patches. Tick it so it loads.') -f $script:ModName) 'Yellow'
                }
            }
        } catch { }
    }

    Say ''
    Say (T 'Ahora:' 'Next steps:') 'Cyan'
    if ($port) {
        # BBPort 1.9.3 moved the languages from "Game & effects" to "Gameplay" (and Quit to Desktop's entry to 110006)
        if (@($quitTexts).Count -ge 2 -and $quitTexts[1].Id -ne 110005) { $page = 'Gameplay' } else { $page = T 'Juego y efectos (Game & effects)' 'Game & effects' }
        Say ((T '  1. Abre BBPort (Bloodborne.exe) > {0} > Text language: Español (Spanish). Con el mod sale en español latino.' `
                '  1. Open BBPort (Bloodborne.exe) > {0} > Text language: Spanish. With the mod it shows Latin American Spanish.') -f $page)
        Say (T '  2. Voice language: Español (América). Las voces latinas ya vienen en BBPort.' `
               '  2. Voice language: Español (América). BBPort already has the Latin American voices.')
        Say ((T '  3. En Mods y parches (Mods & patches) revisa que "{0}" esté marcado (si el launcher ya estaba abierto, da clic en Actualizar / Refresh).' `
                '  3. In Mods & patches, check that "{0}" is ticked (if the launcher was already open, click Refresh).') -f $script:ModName)
        Say (T '     Para volver al español de España, desmárcalo. El portugués de Brasil ya viene en BBPort: elígelo en Text language y Voice language.' `
               '     To go back to Spanish (Spain), untick it. BBPort already has Brazilian Portuguese: choose it in Text language and Voice language.')
        Say (T '  4. Cada vez que actualices BBPort: abre el juego una vez, ciérralo y vuelve a correr este instalador.' `
               '  4. Each time you update BBPort: start the game once, close it and run this installer again.')
        if ($portNote) {
            Say ''
            Say (T 'OJO: todavía no están los textos que BBPort agrega al menú para esta versión o con tus opciones de ahora. Abre el juego una vez desde BBPort (hasta la pantalla de título), ciérralo y vuelve a correr este instalador: así el menú del mod los incluye.' `
                   'NOTE: the texts BBPort adds to the menu aren''t there yet for this version or for your current options. Start the game once from BBPort (up to the title screen), close it and run this installer again: then the mod''s menu has them.') 'Yellow'
        }
    } else {
        if ($launcher) {
            Say ((T '  1. Abre BBLauncher > Mod Manager > en Inactive Mods elige "{0}" > Activate Mod.' `
                    '  1. Open BBLauncher > Mod Manager > under Inactive Mods select "{0}" > Activate Mod.') -f $script:ModName)
            Say (T '     (Si el Mod Manager ya estaba abierto, ciérralo y ábrelo otra vez.)' `
                   '     (If the Mod Manager was already open, close it and open it again.)')
        } else {
            Say ((T '  1. Copia la carpeta dvdroot_ps4 de "{0}" a la carpeta "{1}" (créala si no existe; ver README.txt).' `
                    '  1. Copy the dvdroot_ps4 folder from "{0}" into "{1}" (create it if it doesn''t exist; see README.txt).') -f $output, ($base + '-mods'))
        }
        Say (T '  2. En el juego: OPTIONS > Sistema > Idioma > elige tu idioma en Texto y en Voz ("Predeterminado" no los elige solo).' `
               '  2. In the game: OPTIONS > System > Language > pick your language for Text and Voice ("Default" won''t pick them).')
        Say (T '     Inglés (Estados Unidos) es solo texto: en Voz deja "Inglés (Reino Unido)", es el mismo doblaje.' `
               '     English (United States) is text only: for Voice keep "English (United Kingdom)", it''s the same dub.')
        Say (T '  3. Para el online deja APAGADOS los parches "Unlock Game Region" y "Disable HTTP Requests".' `
               '  3. For online play keep the "Unlock Game Region" and "Disable HTTP Requests" patches OFF.')
    }
    Say ''
    if ($launcher -or $port) {
        if ($launcher) { $where = 'BBLauncher' } else { $where = 'BBPort' }
        # The installer's own folder can go; if its files sit loose among other files, only they can
        $own = @('INSTALL - Americas Language Pack.bat', 'Americas_Language_Pack.ps1', 'README.txt')
        $notOurs = @([IO.Directory]::GetFileSystemEntries($here) | Where-Object { $own -notcontains [IO.Path]::GetFileName($_) })
        if ($notOurs.Count -eq 0) {
            Say ((T 'Ya puedes borrar la carpeta del instalador ("{0}"): el mod ya quedó en {1} y no la necesita.' `
                    'You can delete the installer folder now ("{0}"): the mod is already in {1} and does not need it.') -f [IO.Path]::GetFileName($here), $where) 'Green'
        } else {
            Say (T 'Ya puedes borrar los archivos del instalador (INSTALL - Americas Language Pack.bat, Americas_Language_Pack.ps1 y README.txt): el mod no los necesita.' `
                   'You can delete the installer files now (INSTALL - Americas Language Pack.bat, Americas_Language_Pack.ps1 and README.txt): the mod does not need them.') 'Green'
        }
        if ($launcher) {
            $modsPrefix = [IO.Path]::Combine($launcher, 'Mods') + [IO.Path]::DirectorySeparatorChar
            if ($here.StartsWith($modsPrefix, [StringComparison]::OrdinalIgnoreCase)) {
                Say (T 'OJO: este instalador está dentro de BBLauncher\Mods. Bórralo de ahí para que no salga como mod en el Mod Manager.' `
                       'NOTE: this installer is inside BBLauncher\Mods. Delete it from there so it does not show up as a mod in the Mod Manager.') 'Yellow'
            }
        } else {
            $modsPrefix = $portMods.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
            if ($here.StartsWith($modsPrefix, [StringComparison]::OrdinalIgnoreCase)) {
                Say (T 'OJO: este instalador está dentro de la carpeta mods de BBPort. Bórralo de ahí para que no salga en la lista de mods de BBPort.' `
                       'NOTE: this installer is inside BBPort''s mods folder. Delete it from there so it does not show up in BBPort''s mod list.') 'Yellow'
            }
        }
    } else {
        Say (T 'Cuando hayas copiado el mod, puedes borrar este instalador.' 'Once you have copied the mod, you can delete this installer.') 'Green'
    }
    Say (T 'Guarda el zip: trae el README (desinstalar, actualizar, solución de problemas) y el instalador por si lo vuelves a necesitar.' `
           'Keep the zip: it has the README (uninstall, updates, troubleshooting) and the installer, in case you need it again.')
}

try {
    Invoke-Main
} catch {
    Write-Progress -Activity ' ' -Completed
    Say ''
    Say ((T 'Algo salió mal: {0}' 'Something went wrong: {0}') -f $_.Exception.Message) 'Red'
    if ($script:Building) {
        try {
            if (Remove-OldBuild $script:Building) { Say (T 'Borré el mod incompleto.' 'The incomplete mod was removed.') 'Red' }
        } catch { }
    }
    Say (T 'Tu juego no se modificó.' 'Your game was not modified.') 'Red'
}

if (-not $NoPause) {
    Say ''
    [void](Read-Host (T 'Presiona Enter para cerrar' 'Press Enter to close'))
}
