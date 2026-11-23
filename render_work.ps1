Add-Type -AssemblyName System.Drawing

$outDir = "C:\Users\surya\.gemini\antigravity\scratch\sles1401-highlight-studio\exports"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$W = 1080
$H = 1920

function New-Color($hex, $alpha = 255) {
    $hex = $hex.TrimStart('#')
    $r = [Convert]::ToInt32($hex.Substring(0,2), 16)
    $g = [Convert]::ToInt32($hex.Substring(2,2), 16)
    $b = [Convert]::ToInt32($hex.Substring(4,2), 16)
    return [System.Drawing.Color]::FromArgb($alpha, $r, $g, $b)
}

function New-RoundedRectPath($x, $y, $w, $h, $r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function Start-Canvas($topHex, $botHex, $drawFrame = $true) {
    $bmp = New-Object System.Drawing.Bitmap($W, $H)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, (New-Color $topHex), (New-Color $botHex), 75)
    $g.FillRectangle($brush, $rect)
    $brush.Dispose()

    $grainBrush = New-Object System.Drawing.SolidBrush((New-Color "#2E2A26" 8))
    for ($i = 0; $i -lt 3600; $i++) {
        $gx = ($i * 733) % $W
        $gy = ($i * 1297) % $H
        $g.FillRectangle($grainBrush, $gx, $gy, 2, 2)
    }
    $grainBrush.Dispose()

    if ($drawFrame) {
        $framePen = New-Object System.Drawing.Pen((New-Color "#2E2A26" 36), 2)
        $g.DrawRectangle($framePen, 56, 56, $W - 112, $H - 112)
        $framePen.Dispose()
    }
    return @($bmp, $g)
}

function Draw-HeaderFooter($g, $topLeft, $topRight, $botLeft, $botRight) {
    $font = New-Object System.Drawing.Font("Consolas", 18, [System.Drawing.FontStyle]::Regular)
    $brush = New-Object System.Drawing.SolidBrush((New-Color "#6E675F"))
    $sfRight = New-Object System.Drawing.StringFormat
    $sfRight.Alignment = [System.Drawing.StringAlignment]::Far

    $g.DrawString($topLeft.ToUpper(), $font, $brush, 104, 195)
    $g.DrawString($topRight.ToUpper(), $font, $brush, ($W - 104), 195, $sfRight)

    $pen = New-Object System.Drawing.Pen((New-Color "#2E2A26" 36), 1.5)
    $g.DrawLine($pen, 104, $H - 230, $W - 104, $H - 230)
    $pen.Dispose()

    $g.DrawString($botLeft.ToUpper(), $font, $brush, 104, $H - 195)
    $g.DrawString($botRight.ToUpper(), $font, $brush, ($W - 104), $H - 195, $sfRight)

    $font.Dispose(); $brush.Dispose(); $sfRight.Dispose()
}

function Draw-Pill($g, $text, $x, $y, $colorHex = "#5C554E", $borderAlpha = 58) {
    $font = New-Object System.Drawing.Font("Consolas", 16, [System.Drawing.FontStyle]::Regular)
    $size = $g.MeasureString($text.ToUpper(), $font)
    $pw = [int]$size.Width + 48
    $ph = 52
    $path = New-RoundedRectPath $x $y $pw $ph 26
    $pen = New-Object System.Drawing.Pen((New-Color $colorHex $borderAlpha), 2)
    $g.DrawPath($pen, $path)
    $brush = New-Object System.Drawing.SolidBrush((New-Color $colorHex))
    $g.DrawString($text.ToUpper(), $font, $brush, ($x + 24), ($y + 13))
    $path.Dispose(); $pen.Dispose(); $brush.Dispose(); $font.Dispose()
    return ($y + $ph)
}

function Save-Canvas($bmp, $g, $filename) {
    $path = Join-Path $outDir $filename
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Output "Saved $path"
}

# 1. Cover: cover-work.png
$res = Start-Canvas "#F4EFE6" "#E4DBCA" $false
$bmp = $res[0]; $g = $res[1]
$cx = $W / 2; $cy = $H / 2
$circleBrush = New-Object System.Drawing.SolidBrush((New-Color "#F4EFE6"))
$circlePen = New-Object System.Drawing.Pen((New-Color "#2E2A26" 42), 2.5)
$g.FillEllipse($circleBrush, $cx - 330, $cy - 330, 660, 660)
$g.DrawEllipse($circlePen, $cx - 330, $cy - 330, 660, 660)

# Minimalist window / QA checklist icon
$iconPen = New-Object System.Drawing.Pen((New-Color "#6B7B63"), 4)
$iconFill = New-Object System.Drawing.SolidBrush((New-Color "#DCE2D7" 115))
$iy = $cy - 95
$box = New-RoundedRectPath ($cx - 82) $iy 164 118 14
$g.FillPath($iconFill, $box)
$g.DrawPath($iconPen, $box)
$g.DrawLine($iconPen, ($cx - 82), ($iy + 32), ($cx + 82), ($iy + 32))
# Checkmark + lines inside
$accentPen = New-Object System.Drawing.Pen((New-Color "#B87A5E"), 4.5)
$g.DrawLine($accentPen, ($cx - 48), ($iy + 74), ($cx - 34), ($iy + 88))
$g.DrawLine($accentPen, ($cx - 34), ($iy + 88), ($cx - 10), ($iy + 60))
$g.DrawLine($iconPen, ($cx + 8), ($iy + 66), ($cx + 52), ($iy + 66))
$g.DrawLine($iconPen, ($cx + 8), ($iy + 86), ($cx + 42), ($iy + 86))

$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$titleFont = New-Object System.Drawing.Font("Georgia", 46, [System.Drawing.FontStyle]::Regular)
$subFont = New-Object System.Drawing.Font("Consolas", 17, [System.Drawing.FontStyle]::Regular)
$inkBrush = New-Object System.Drawing.SolidBrush((New-Color "#2E2A26"))
$mutedBrush = New-Object System.Drawing.SolidBrush((New-Color "#7D756C"))
$g.DrawString("WORK", $titleFont, $inkBrush, $cx, $cy + 65, $sfCenter)
$g.DrawString("@SLES1401", $subFont, $mutedBrush, $cx, $cy + 145, $sfCenter)
Save-Canvas $bmp $g "cover-work.png"

# 2. Slide 1: work-1-intro.png
$res = Start-Canvas "#E7ECE3" "#DCE2D7" $true
$bmp = $res[0]; $g = $res[1]
Draw-HeaderFooter $g "@sles1401 · Work & QA" "01 / 04" "Software & Quality" "Craft & Care"
$y = Draw-Pill $g "Work / QA Log" 104 340 "#41523A" 75
$hFont = New-Object System.Drawing.Font("Georgia", 62, [System.Drawing.FontStyle]::Regular)
$hItalic = New-Object System.Drawing.Font("Georgia", 62, [System.Drawing.FontStyle]::Italic)
$inkBrush = New-Object System.Drawing.SolidBrush((New-Color "#2E2A26"))
$sageBrush = New-Object System.Drawing.SolidBrush((New-Color "#6B7B63"))
$g.DrawString("Building with", $hFont, $inkBrush, 104, $y + 55)
$g.DrawString("Clarity & Care.", $hItalic, $sageBrush, 104, $y + 145)

$bodyFont = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Regular)
$bodyBrush = New-Object System.Drawing.SolidBrush((New-Color "#3D3833"))
$rectBody = New-Object System.Drawing.RectangleF(104, ($y + 295), 860, 260)
$g.DrawString("Bagian ini merangkum perjalananku di balik layar: mulai dari pengembangan Front-End, perhatian pada detail QA, hingga mentoring.", $bodyFont, $bodyBrush, $rectBody)

$cardPath = New-RoundedRectPath 104 ($y + 585) 872 175 20
$cardBrush = New-Object System.Drawing.SolidBrush((New-Color "#FAF7F2"))
$cardPen = New-Object System.Drawing.Pen((New-Color "#2E2A26" 32), 2)
$g.FillPath($cardBrush, $cardPath)
$g.DrawPath($cardPen, $cardPath)
$qFont = New-Object System.Drawing.Font("Georgia", 25, [System.Drawing.FontStyle]::Italic)
$clayBrush = New-Object System.Drawing.SolidBrush((New-Color "#B87A5E"))
$rectQ = New-Object System.Drawing.RectangleF(144, ($y + 628), 790, 120)
$g.DrawString(([char]0x201C + "Kualitas produk lahir dari rasa peduli pada pengalaman penggunanya." + [char]0x201D), $qFont, $clayBrush, $rectQ)
Save-Canvas $bmp $g "work-1-intro.png"

# 3. Slide 2: work-2-waizly.png
$res = Start-Canvas "#F5F0E7" "#EAE1D2" $true
$bmp = $res[0]; $g = $res[1]
Draw-HeaderFooter $g "@sles1401 · Internship" "02 / 04" "Front-End & QA" "Waizly"
$y = Draw-Pill $g "Internship Experience" 104 320 "#9B6247" 90
$hFont = New-Object System.Drawing.Font("Georgia", 48, [System.Drawing.FontStyle]::Regular)
$inkBrush = New-Object System.Drawing.SolidBrush((New-Color "#2E2A26"))
$rectH = New-Object System.Drawing.RectangleF(104, ($y + 48), 870, 175)
$g.DrawString("Front-End Developer Intern at Waizly", $hFont, $inkBrush, $rectH)

$cards = @(
    @{ tag = "01 / IMPLEMENTASI UI"; color = "#8C9A84"; text = "Membangun tampilan antarmuka web yang rapi, terstruktur, dan nyaman digunakan." },
    @{ tag = "02 / DETAIL & KUALITAS"; color = "#B87A5E"; text = "Membiasakan pengecekan edge case, responsivitas, dan konsistensi UI sebelum rilis." }
)
$cy = $y + 255
foreach ($c in $cards) {
    $cPath = New-RoundedRectPath 104 $cy 872 215 18
    $cBrush = New-Object System.Drawing.SolidBrush((New-Color "#FAF7F2"))
    $g.FillPath($cBrush, $cPath)
    $barBrush = New-Object System.Drawing.SolidBrush((New-Color $c.color))
    $g.FillRectangle($barBrush, 104, $cy, 8, 215)
    $tFont = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Regular)
    $g.DrawString($c.tag, $tFont, $barBrush, 144, $cy + 34)
    $bFont = New-Object System.Drawing.Font("Segoe UI", 26, [System.Drawing.FontStyle]::Regular)
    $rectC = New-Object System.Drawing.RectangleF(144, ($cy + 78), 790, 130)
    $g.DrawString($c.text, $bFont, $inkBrush, $rectC)
    $cy += 245
}

$noteFont = New-Object System.Drawing.Font("Georgia", 26, [System.Drawing.FontStyle]::Italic)
$sageBrush = New-Object System.Drawing.SolidBrush((New-Color "#6B7B63"))
$rectN = New-Object System.Drawing.RectangleF(104, ($cy + 25), 860, 120)
$g.DrawString("Pengalaman awal di dunia kerja yang melatih ketelitian dan rasa tanggung jawab terhadap detail.", $noteFont, $sageBrush, $rectN)
Save-Canvas $bmp $g "work-2-waizly.png"

# 4. Slide 3: work-3-mentoring.png
$res = Start-Canvas "#F4EFE6" "#E8DFCF" $true
$bmp = $res[0]; $g = $res[1]
Draw-HeaderFooter $g "@sles1401 · Mentorship" "03 / 04" "Community & Teaching" "DBS Foundation"
$y = Draw-Pill $g "Mentoring Journey" 104 320 "#41523A" 75
$hFont = New-Object System.Drawing.Font("Georgia", 46, [System.Drawing.FontStyle]::Regular)
$inkBrush = New-Object System.Drawing.SolidBrush((New-Color "#2E2A26"))
$rectH = New-Object System.Drawing.RectangleF(104, ($y + 48), 870, 185)
$g.DrawString("Mentor Coding Camp by DBS Foundation", $hFont, $inkBrush, $rectH)

$cardPath = New-RoundedRectPath 104 ($y + 260) 872 340 22
$cardBrush = New-Object System.Drawing.SolidBrush((New-Color "#FAF7F2"))
$cardPen = New-Object System.Drawing.Pen((New-Color "#2E2A26" 32), 2)
$g.FillPath($cardBrush, $cardPath)
$g.DrawPath($cardPen, $cardPath)

$bodyFont = New-Object System.Drawing.Font("Segoe UI", 27, [System.Drawing.FontStyle]::Regular)
$bodyBrush = New-Object System.Drawing.SolidBrush((New-Color "#3D3833"))
$rectB = New-Object System.Drawing.RectangleF(148, ($y + 312), 784, 260)
$g.DrawString("Mendampingi peserta memahami fondasi pemrograman, berdiskusi soal alur logika, dan membantu mereka melewati kebuntuan saat belajar.", $bodyFont, $bodyBrush, $rectB)

$qFont = New-Object System.Drawing.Font("Georgia", 26, [System.Drawing.FontStyle]::Italic)
$clayBrush = New-Object System.Drawing.SolidBrush((New-Color "#B87A5E"))
$rectQ = New-Object System.Drawing.RectangleF(104, ($y + 655), 860, 160)
$g.DrawString(([char]0x201C + "Mengajar adalah cara terbaik untuk ikut bertumbuh dan menjaga empati terhadap proses belajar." + [char]0x201D), $qFont, $clayBrush, $rectQ)
Save-Canvas $bmp $g "work-3-mentoring.png"

# 5. Slide 4: work-4-projects.png
$res = Start-Canvas "#EFE8DA" "#E4DAC8" $true
$bmp = $res[0]; $g = $res[1]
Draw-HeaderFooter $g "@sles1401 · Portfolio" "04 / 04" "Selected Works" "suryani-lestari.my.id"
$y = Draw-Pill $g "Projects & Showcase" 104 330
$hFont = New-Object System.Drawing.Font("Georgia", 46, [System.Drawing.FontStyle]::Regular)
$inkBrush = New-Object System.Drawing.SolidBrush((New-Color "#2E2A26"))
$rectH = New-Object System.Drawing.RectangleF(104, ($y + 48), 870, 220)
$g.DrawString("Ingin lihat cuplikan proyek & catatan lengkapku?", $hFont, $inkBrush, $rectH)

$cardPath = New-RoundedRectPath 104 ($y + 310) 872 240 20
$cardBrush = New-Object System.Drawing.SolidBrush((New-Color "#FAF7F2"))
$cardPen = New-Object System.Drawing.Pen((New-Color "#2E2A26" 34), 2)
$g.FillPath($cardBrush, $cardPath)
$g.DrawPath($cardPen, $cardPath)
$lblFont = New-Object System.Drawing.Font("Consolas", 15, [System.Drawing.FontStyle]::Regular)
$sageBrush = New-Object System.Drawing.SolidBrush((New-Color "#6B7B63"))
$g.DrawString("PORTFOLIO WEBSITE", $lblFont, $sageBrush, 144, $y + 353)
$bFont = New-Object System.Drawing.Font("Segoe UI", 27, [System.Drawing.FontStyle]::Regular)
$rectP = New-Object System.Drawing.RectangleF(144, ($y + 400), 790, 130)
$g.DrawString("Studi kasus web, pengalaman teknis, dan profil lengkap tersedia di suryani-lestari.my.id", $bFont, $inkBrush, $rectP)

$boxPath = New-RoundedRectPath 104 ($y + 610) 872 170 18
$boxBrush = New-Object System.Drawing.SolidBrush((New-Color "#DCE2D7" 100))
$boxPen = New-Object System.Drawing.Pen((New-Color "#6B7B63" 130), 2)
$boxPen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
$g.FillPath($boxBrush, $boxPath)
$g.DrawPath($boxPen, $boxPath)

$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sageDark = New-Object System.Drawing.SolidBrush((New-Color "#545D50"))
$qFont = New-Object System.Drawing.Font("Georgia", 24, [System.Drawing.FontStyle]::Italic)
$g.DrawString("AREA STIKER LINK KE PORTFOLIO", $lblFont, $sageDark, ($W / 2), ($y + 653), $sfCenter)
$g.DrawString("suryani-lestari.my.id", $qFont, $inkBrush, ($W / 2), ($y + 703), $sfCenter)
Save-Canvas $bmp $g "work-4-projects.png"
