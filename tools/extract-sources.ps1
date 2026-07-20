<#
.SYNOPSIS
    Витягує лише англійські <source> з діалогових вузлів — без <target>.

.DESCRIPTION
    Картки стилю (style.yaml) мають будуватися виключно з англійського джерела:
    ~98% цілей у dialogs/ — сирий машинний переклад, і читання його отруїло б
    висновки про регістр. Цей скрипт робить таку вимогу структурною, а не
    інструкцією, яку агент може тихо порушити: на виході лишається сам текст
    джерела, а <target>, <mda:*> та решта XML-обгортки не потрапляють нікуди.

    Один вузол — один .txt на виході. Формат рядка:

        q1<TAB>текст джерела

    Порожні юніти (джерело складається лише з <end>) відкидаються — це вузли
    розгалуження діалогу, вони не несуть сигналу про мовця чи регістр.
    Справжні переводи рядків замінюються на літерал \n, щоб один юніт завжди
    лишався одним рядком і файл можна було читати построково.

.EXAMPLE
    pwsh tools/extract-sources.ps1 -OutDir ../sources
    pwsh tools/extract-sources.ps1 -Path dialogs/events -OutDir ../sources
#>
[CmdletBinding()]
param(
    [string]$Path = '.',
    [Parameter(Mandatory)][string]$OutDir,
    [switch]$IncludeEmpty
)

$ns = @{ x = 'urn:oasis:names:tc:xliff:document:2.0' }

if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

# Шляхи вузлів рахуємо від кореня репозиторію, а не від -Path: інакше вибірка
# по одній категорії дала б «finalcouncil» замість «dialogs/events/finalcouncil».
$root = (Get-Location).Path
$nodes = 0
$written = 0
$skipped = 0

foreach ($file in Get-ChildItem -Path $Path -Recurse -Filter uk.xml) {
    try {
        $doc = [xml](Get-Content $file.FullName -Raw)
    }
    catch {
        Write-Warning "xml-parse :: $($file.FullName) — $($_.Exception.Message)"
        continue
    }

    $nodes++

    # Відносний шлях вузла, завжди зі скісною рискою вперед: dialogs/characters/xpbl/ferryman
    $nodeDir = Split-Path $file.FullName -Parent
    $rel = $nodeDir.Substring($root.Length).TrimStart('\', '/') -replace '\\', '/'

    $fileEl = (Select-Xml -Xml $doc -XPath '//x:file' -Namespace $ns | Select-Object -First 1).Node
    $fileId = [string]$fileEl.id

    $lines = @()
    foreach ($node in Select-Xml -Xml $doc -XPath '//x:unit' -Namespace $ns) {
        $unit = $node.Node
        $seg = $unit.segment
        if (-not $seg) { continue }

        # Той самий трюк, що в check-uk.ps1: <source> без атрибутів приходить
        # рядком, а не XmlElement, і .InnerText мовчки віддає порожнечу.
        $srcNode = $seg.ChildNodes | Where-Object { $_.LocalName -eq 'source' } | Select-Object -First 1
        $src = [string]$srcNode.InnerText

        $bare = ($src -replace '<end>', '').Trim()
        if (-not $IncludeEmpty -and $bare -eq '') { $skipped++; continue }

        $flat = $src -replace "`r`n", '\n' -replace "`n", '\n' -replace "`t", ' '
        $lines += "{0}`t{1}" -f $unit.id, $flat
    }

    if ($lines.Count -eq 0) { continue }

    $header = @(
        "# node: $rel"
        "# file_id: $fileId"
        "# units_with_text: $($lines.Count)"
        '# УВАГА: це лише англійське джерело. Українських цілей тут немає навмисно.'
        ''
    )

    $outName = ($rel -replace '^dialogs/', '' -replace '/', '__') + '.txt'
    $outPath = Join-Path $OutDir $outName
    Set-Content -Path $outPath -Value ($header + $lines) -Encoding UTF8
    $written++
}

Write-Host "Вузлів прочитано: $nodes"
Write-Host "Файлів записано:  $written"
Write-Host "Порожніх юнітів відкинуто: $skipped"
