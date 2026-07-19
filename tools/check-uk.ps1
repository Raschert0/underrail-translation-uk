<#
.SYNOPSIS
    Перевіряє механічну цілісність розмітки у відредагованих людиною сегментах.

.DESCRIPTION
    Обробляє лише сегменти з <target state="translated"> — тобто відредаговані людиною.
    Машинні сегменти (needs-translation) ігноруються: вони ще будуть перекладені наново.

    Перевіряє:
      * <end>            — присутній у джерелі, має бути присутній у цілі
      * ::               — кількість роздільників має збігатися
      * {N}              — набір підстановок має збігатися
      * $(context.…)     — набір має збігатися
      * $(#…)            — усередині не має лишатися латиниці (неперекладений плейсхолдер)

    Стилю, термінології та граматики НЕ перевіряє.

.EXAMPLE
    pwsh tools/check-uk.ps1
    pwsh tools/check-uk.ps1 -Path dialogs/characters
#>
[CmdletBinding()]
param(
    [string]$Path = '.'
)

$ns = @{ x = 'urn:oasis:names:tc:xliff:document:2.0' }
$problems = @()
$edited = 0

foreach ($file in Get-ChildItem -Path $Path -Recurse -Filter uk.xml) {
    try {
        $doc = [xml](Get-Content $file.FullName -Raw)
    }
    catch {
        $problems += [pscustomobject]@{
            Kind = 'xml-parse'; File = $file.FullName; Unit = ''; Detail = $_.Exception.Message
        }
        continue
    }

    $rel = Resolve-Path $file.FullName -Relative

    foreach ($node in Select-Xml -Xml $doc -XPath '//x:unit' -Namespace $ns) {
        $unit = $node.Node
        $seg = $unit.segment
        if (-not $seg) { continue }
        if ($seg.target.state -ne 'translated') { continue }

        $edited++
        # <source> не має атрибутів, тому PowerShell віддає його як рядок, а не як
        # XmlElement — і .InnerText мовчки повертає порожнечу. Беремо вузол напряму.
        $srcNode = $seg.ChildNodes | Where-Object { $_.LocalName -eq 'source' } | Select-Object -First 1
        $trgNode = $seg.ChildNodes | Where-Object { $_.LocalName -eq 'target' } | Select-Object -First 1
        $src = [string]$srcNode.InnerText
        $trg = [string]$trgNode.InnerText

        $add = {
            param($kind, $detail)
            $script:problems += [pscustomobject]@{
                Kind = $kind; File = $rel; Unit = $unit.id; Detail = $detail
            }
        }

        if ($src -match '<end>' -and $trg -notmatch '<end>') {
            & $add 'end-missing' 'джерело має <end>, ціль — ні'
        }

        $srcColons = ([regex]::Matches($src, '::')).Count
        $trgColons = ([regex]::Matches($trg, '::')).Count
        if ($srcColons -ne $trgColons) {
            & $add 'colon-count' "джерело=$srcColons ціль=$trgColons"
        }

        $srcBraces = (([regex]::Matches($src, '\{\d+\}') | ForEach-Object { $_.Value }) | Sort-Object) -join ','
        $trgBraces = (([regex]::Matches($trg, '\{\d+\}') | ForEach-Object { $_.Value }) | Sort-Object) -join ','
        if ($srcBraces -ne $trgBraces) {
            & $add 'placeholder' "джерело=[$srcBraces] ціль=[$trgBraces]"
        }

        $srcCtx = (([regex]::Matches($src, '\$\(context\.[^)]*\)') | ForEach-Object { $_.Value }) | Sort-Object) -join ','
        $trgCtx = (([regex]::Matches($trg, '\$\(context\.[^)]*\)') | ForEach-Object { $_.Value }) | Sort-Object) -join ','
        if ($srcCtx -ne $trgCtx) {
            & $add 'context-var' "джерело=[$srcCtx] ціль=[$trgCtx]"
        }

        foreach ($m in [regex]::Matches($trg, '\$\(#([^)]*)\)')) {
            if ($m.Groups[1].Value -match '^[\x00-\x7F]+$') {
                & $add 'gender-latin' "неперекладений плейсхолдер: $($m.Value)"
            }
        }
    }
}

Write-Host "Перевірено відредагованих сегментів: $edited"

if ($problems.Count -eq 0) {
    Write-Host 'OK — порушень не знайдено.' -ForegroundColor Green
    exit 0
}

Write-Host "Знайдено порушень: $($problems.Count)" -ForegroundColor Red
$problems | Group-Object Kind | Sort-Object Count -Descending | ForEach-Object {
    Write-Host ''
    Write-Host "=== $($_.Name): $($_.Count) ===" -ForegroundColor Yellow
    $_.Group | ForEach-Object { "  {0} :: {1} — {2}" -f $_.File, $_.Unit, $_.Detail }
}
exit 1
