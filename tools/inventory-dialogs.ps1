<#
.SYNOPSIS
    Механічна інвентаризація діалогових вузлів — сировина для карток стилю.

.DESCRIPTION
    Рахує те, що можна порахувати без моделі, щоб агенти не витрачали на це
    контекст і не помилялися:

      * manifest.csv — вузол, file_id, кількість юнітів (усього / q / a / порожніх)
      * gender-cues   — усі різні $(#…) з q-рядків; найсильніший сигнал регістру
      * narration     — власні назви всередині ::…::; головна зачіпка для атрибуції
      * names.csv     — усі капіталізовані токени по корпусу з лічильником вузлів

    Працює лише з <source>. <target> не читається взагалі.

.EXAMPLE
    pwsh tools/inventory-dialogs.ps1 -OutDir ../inventory
#>
[CmdletBinding()]
param(
    [string[]]$Path = @('dialogs/characters', 'dialogs/events'),
    [Parameter(Mandatory)][string]$OutDir
)

$ns = @{ x = 'urn:oasis:names:tc:xliff:document:2.0' }

if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

# Службові слова, що стоять на початку речення в нарації й не є іменами.
$stop = @(
    'He','She','It','They','You','His','Her','Their','Your','The','A','An','I',
    'This','That','These','Those','There','Here','As','After','Before','When',
    'While','With','Without','If','But','And','Or','So','Then','Now','Once',
    'Suddenly','Finally','Slowly','Quickly','Both','One','Two','Not','No','Yes',
    'What','Who','Why','How','Where','Whatever','Nothing','Something','Someone',
    'Everyone','Everything','Nobody','Anyone','Barter','Leave','Continue','Attack',
    'Fight','Nod','Give','Take','Ask','Tell','Say','Go','Stop','Wait','Back'
) | ForEach-Object { $_.ToLower() }
$stopSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$stop)

$root = (Get-Location).Path
$rows = @()
$nameCount = @{}

foreach ($p in $Path) {
    foreach ($file in Get-ChildItem -Path $p -Recurse -Filter uk.xml) {
        try { $doc = [xml](Get-Content $file.FullName -Raw) }
        catch { Write-Warning "xml-parse :: $($file.FullName)"; continue }

        $nodeDir = Split-Path $file.FullName -Parent
        $rel = $nodeDir.Substring($root.Length).TrimStart('\', '/') -replace '\\', '/'
        $fileEl = (Select-Xml -Xml $doc -XPath '//x:file' -Namespace $ns | Select-Object -First 1).Node

        $q = 0; $a = 0; $empty = 0
        $cues = @{}
        $genders = @{}
        $nodeNames = @{}

        foreach ($node in Select-Xml -Xml $doc -XPath '//x:unit' -Namespace $ns) {
            $unit = $node.Node
            $seg = $unit.segment
            if (-not $seg) { continue }
            $srcNode = $seg.ChildNodes | Where-Object { $_.LocalName -eq 'source' } | Select-Object -First 1
            $src = [string]$srcNode.InnerText

            $id = [string]$unit.id
            $isPlayer = $id -match '^=>a\d+$'
            if ($isPlayer) { $a++ } else { $q++ }

            if (($src -replace '<end>', '').Trim() -eq '') { $empty++; continue }

            # $(#…) лише з q-рядків: це те, як NPC звертається до гравця.
            if (-not $isPlayer) {
                foreach ($m in [regex]::Matches($src, '\$\(#[^)]*\)')) { $genders[$m.Value] = 1 }
            }

            # Власні назви всередині ::…:: — зачіпка для атрибуції мовця.
            foreach ($m in [regex]::Matches($src, '::(.+?)::')) {
                foreach ($t in [regex]::Matches($m.Groups[1].Value, '\b[A-Z][a-zA-Z''\-]{2,}\b')) {
                    $tok = $t.Value
                    if ($stopSet.Contains($tok.ToLower())) { continue }
                    $cues[$tok] = 1
                }
            }

            # Загальний іменний інвентар — по всьому тексту юніта.
            foreach ($t in [regex]::Matches($src, '\b[A-Z][a-zA-Z''\-]{2,}\b')) {
                $tok = $t.Value
                if ($stopSet.Contains($tok.ToLower())) { continue }
                $nodeNames[$tok] = 1
            }
        }

        foreach ($n in $nodeNames.Keys) {
            if (-not $nameCount.ContainsKey($n)) { $nameCount[$n] = @() }
            $nameCount[$n] += $rel
        }

        $rows += [pscustomobject]@{
            node          = $rel
            file_id       = [string]$fileEl.id
            total         = $q + $a
            q             = $q
            a             = $a
            empty         = $empty
            gender_cues   = (($genders.Keys | Sort-Object) -join ' ')
            narration_names = (($cues.Keys | Sort-Object) -join ' ')
        }
    }
}

$rows = $rows | Sort-Object node
$rows | Export-Csv -Path (Join-Path $OutDir 'manifest.csv') -NoTypeInformation -Encoding UTF8

$nameRows = $nameCount.GetEnumerator() | ForEach-Object {
    [pscustomobject]@{
        name       = $_.Key
        node_count = $_.Value.Count
        nodes      = (($_.Value | Sort-Object) -join ' ')
    }
} | Sort-Object node_count -Descending
$nameRows | Export-Csv -Path (Join-Path $OutDir 'names.csv') -NoTypeInformation -Encoding UTF8

Write-Host "Вузлів:              $($rows.Count)"
Write-Host "Юнітів усього:       $(($rows | Measure-Object total -Sum).Sum)"
Write-Host "  q (NPC/нарація):   $(($rows | Measure-Object q -Sum).Sum)"
Write-Host "  a (гравець):       $(($rows | Measure-Object a -Sum).Sum)"
Write-Host "  порожніх:          $(($rows | Measure-Object empty -Sum).Sum)"
Write-Host "Вузлів без `$(#…):    $(($rows | Where-Object { $_.gender_cues -eq '' }).Count)"
Write-Host "Вузлів із назвами в нарації: $(($rows | Where-Object { $_.narration_names -ne '' }).Count)"
Write-Host "Різних капіталізованих токенів: $($nameRows.Count)"
