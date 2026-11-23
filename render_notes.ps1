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

    # Subtle paper grain
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

# 1. Cover: cover-notes.png
$res = Start-Canvas "#F4EFE6" "#E4DBCA" $false
$bmp = $res[0]; $g = $res[1]
$cx = $W / 2; $cy = $H / 2
$circleBrush = New-Object System.Drawing.SolidBrush((New-Color "#F4EFE6"))
$circlePen = New-Object System.Drawing.Pen((New-Color "#2E2A26" 42), 2.5)
$g.FillEllipse($circleBrush, $cx - 330, $cy - 330, 660, 660)
$g.DrawEllipse($circlePen, $cx - 330, $cy - 330, 660, 660)

# Open book line art
$bookPen = New-Object System.Drawing.Pen((New-Color "#6B7B63"), 4)
$bookFill = New-Object System.Drawing.SolidBrush((New-Color "#DCE2D7" 115))
$bookPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$iy = $cy - 50
$bookPath.AddBezier($cx, $iy - 35, $cx - 45, $iy - 52, $cx - 75, $iy - 38, $cx - 90, $iy - 28)
$bookPath.AddLine($cx - 90, $iy - 28, $cx - 90, $iy + 55)
$bookPath.AddBezier($cx - 90, $iy + 55, $cx - 45, $iy + 36, $cx - 20, $iy + 42, $cx, $iy + 55)
$bookPath.AddBezier($cx, $iy + 55, $cx + 20, $iy + 42, $cx + 45, $iy + 36, $cx + 90, $iy + 55)
$bookPath.AddLine($cx + 90, $iy + 55, $cx + 90, $iy - 28)
$bookPath.AddBezier($cx + 90, $iy - 28, $cx + 75, $iy - 38, $cx + 45, $iy - 52, $cx, $iy - 35)
$bookPath.CloseFigure()
$g.FillPath($bookFill, $bookPath)
$g.DrawPath($bookPen, $bookPath)
$g.DrawLine($bookPen, $cx, $iy - 35, $cx, $iy + 55)

$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$titleFont = New-Object System.Drawing.Font("Georgia", 46, [System.Drawing.FontStyle]::Regular)
$subFont = New-Object System.Drawing.Font("Consolas", 17, [System.Drawing.FontStyle]::Regular)
$inkBrush = New-Object System.Drawing.SolidBrush((New-Color "#2E2A26"))
$mutedBrush = New-Object System.Drawing.SolidBrush((New-Color "#7D756C"))
$g.DrawString("NOTES", $titleFont, $inkBrush, $cx, $cy + 65, $sfCenter)
$g.DrawString("@SLES1401", $subFont, $mutedBrush, $cx, $cy + 145, $sfCenter)
Save-Canvas $bmp $g "cover-notes.png"

# 2. Slide 1: notes-1-intro.png
$res = Start-Canvas "#F5F0E7" "#EAE1D2" $true
$bmp = $res[0]; $g = $res[1]
Draw-HeaderFooter $g "@sles1401 · Learning Archive" "NOTES / LEARN" "Reading & Tech Log" "Slow Reflection"
$y = Draw-Pill $g "Arsip Refleksi" 104 340
$hFont = New-Object System.Drawing.Font("Georgia", 64, [System.Drawing.FontStyle]::Regular)
$hItalic = New-Object System.Drawing.Font("Georgia", 64, [System.Drawing.FontStyle]::Italic)
$inkBrush = New-Object System.Drawing.SolidBrush((New-Color "#2E2A26"))
$clayBrush = New-Object System.Drawing.SolidBrush((New-Color "#B87A5E"))
$g.DrawString("Notes &", $hFont, $inkBrush, 104, $y + 55)
$g.DrawString("Quiet Learnings.", $hItalic, $clayBrush, 104, $y + 150)

$bodyFont = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Regular)
$bodyBrush = New-Object System.Drawing.SolidBrush((New-Color "#3D3833"))
$rectBody = New-Object System.Drawing.RectangleF(104, ($y + 305), 860, 260)
$g.DrawString("Kumpulan catatan singkat dari buku yang kubaca, hal baru di dunia software/QA, dan pelajaran kecil yang ingin kuingat.", $bodyFont, $bodyBrush, $rectBody)

$cardPath = New-RoundedRectPath 104 ($y + 600) 872 175 20
$cardBrush = New-Object System.Drawing.SolidBrush((New-Color "#FAF7F2"))
$cardPen = New-Object System.Drawing.Pen((New-Color "#2E2A26" 32), 2)
$g.FillPath($cardBrush, $cardPath)
$g.DrawPath($cardPen, $cardPath)
$qFont = New-Object System.Drawing.Font("Georgia", 25, [System.Drawing.FontStyle]::Italic)
$sageBrush = New-Object System.Drawing.SolidBrush((New-Color "#6B7B63"))
$rectQ = New-Object System.Drawing.RectangleF(144, ($y + 642), 790, 120)
$g.DrawString(([char]0x201C + "Belajar bukan lomba cepat, tapi proses merawat rasa ingin tahu." + [char]0x201D), $qFont, $sageBrush, $rectQ)
Save-Canvas $bmp $g "notes-1-intro.png"

# 3. Slide 2: notes-2-tech.png
$res = Start-Canvas "#E7ECE3" "#DCE2D7" $true
$bmp = $res[0]; $g = $res[1]
Draw-HeaderFooter $g "@sles1401 · Tech Note" "ARCHIVE #01" "Software & QA" "Field Notes"
$y = Draw-Pill $g "Tech / QA Note" 104 330 "#41523A" 75
$hFont = New-Object System.Drawing.Font("Georgia", 46, [System.Drawing.FontStyle]::Regular)
$inkBrush = New-Object System.Drawing.SolidBrush((New-Color "#2E2A26"))
$rectH = New-Object System.Drawing.RectangleF(104, ($y + 50), 870, 180)
$g.DrawString("1 hal yang kupelajari tentang QA & Testing:", $hFont, $inkBrush, $rectH)

$cardPath = New-RoundedRectPath 104 ($y + 250) 872 360 22
$cardBrush = New-Object System.Drawing.SolidBrush((New-Color "#FAF7F2"))
$cardPen = New-Object System.Drawing.Pen((New-Color "#2E2A26" 32), 2)
$g.FillPath($cardBrush, $cardPath)
$g.DrawPath($cardPen, $cardPath)
$bodyFont = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Regular)
$bodyBrush = New-Object System.Drawing.SolidBrush((New-Color "#3D3833"))
$rectB = New-Object System.Drawing.RectangleF(148, ($y + 305), 784, 270)
$g.DrawString("Menulis test case bukan sekadar mencari bug, tapi memastikan pengalaman pengguna tetap tenang dan dapat diandalkan.", $bodyFont, $bodyBrush, $rectB)

$lblFont = New-Object System.Drawing.Font("Consolas", 15, [System.Drawing.FontStyle]::Regular)
$sageBrush = New-Object System.Drawing.SolidBrush((New-Color "#6B7B63"))
$g.DrawString("KEY TAKEAWAY", $lblFont, $sageBrush, 104, $y + 670)
$tkFont = New-Object System.Drawing.Font("Georgia", 28, [System.Drawing.FontStyle]::Italic)
$rectTk = New-Object System.Drawing.RectangleF(104, ($y + 715), 860, 140)
$g.DrawString("→ Detail kecil hari ini menyelamatkan waktu esok hari.", $tkFont, $inkBrush, $rectTk)
Save-Canvas $bmp $g "notes-2-tech.png"

# 4. Slide 3: notes-3-book.png
$res = Start-Canvas "#F4EFE6" "#E8DFCF" $true
$bmp = $res[0]; $g = $res[1]
Draw-HeaderFooter $g "@sles1401 · Book Note" "ARCHIVE #02" "Reading Log" "Intentional Living"
$y = Draw-Pill $g "Reading Note" 104 330 "#9B6247" 90
$hFont = New-Object System.Drawing.Font("Georgia", 46, [System.Drawing.FontStyle]::Regular)
$inkBrush = New-Object System.Drawing.SolidBrush((New-Color "#2E2A26"))
$rectH = New-Object System.Drawing.RectangleF(104, ($y + 50), 870, 180)
$g.DrawString("Catatan dari Bacaan Minggu Ini", $hFont, $inkBrush, $rectH)

$bkFont = New-Object System.Drawing.Font("Segoe UI", 25, [System.Drawing.FontStyle]::Bold)
$clayBrush = New-Object System.Drawing.SolidBrush((New-Color "#B87A5E"))
$g.DrawString("Deep Work — Cal Newport", $bkFont, $clayBrush, 104, $y + 235)

$cardPath = New-RoundedRectPath 104 ($y + 305) 872 390 22
$cardBrush = New-Object System.Drawing.SolidBrush((New-Color "#FAF7F2"))
$g.FillPath($cardBrush, $cardPath)
$g.FillRectangle($clayBrush, 104, ($y + 305), 8, 390)

$qFont = New-Object System.Drawing.Font("Georgia", 28, [System.Drawing.FontStyle]::Italic)
$rectQ = New-Object System.Drawing.RectangleF(152, ($y + 360), 780, 300)
$g.DrawString(([char]0x201C + "Fokus tanpa gangguan adalah keterampilan langka. Di dunia tech yang serba cepat, memberi ruang hening untuk berpikir justru menjadi keunggulan." + [char]0x201D), $qFont, $inkBrush, $rectQ)
Save-Canvas $bmp $g "notes-3-book.png"

# 5. Slide 4: notes-4-reflection.png
$res = Start-Canvas "#EFE8DA" "#E4DAC8" $true
$bmp = $res[0]; $g = $res[1]
Draw-HeaderFooter $g "@sles1401 · Gentle Reminder" "ARCHIVE #03" "Slow Growth" "Keep Learning"
$y = Draw-Pill $g "Mindful Note" 104 350
$hFont = New-Object System.Drawing.Font("Georgia", 48, [System.Drawing.FontStyle]::Regular)
$inkBrush = New-Object System.Drawing.SolidBrush((New-Color "#2E2A26"))
$rectH = New-Object System.Drawing.RectangleF(104, ($y + 55), 870, 170)
$g.DrawString("Catatan untuk Diri Sendiri", $hFont, $inkBrush, $rectH)

$bodyFont = New-Object System.Drawing.Font("Segoe UI", 30, [System.Drawing.FontStyle]::Regular)
$bodyBrush = New-Object System.Drawing.SolidBrush((New-Color "#3D3833"))
$rectB = New-Object System.Drawing.RectangleF(104, ($y + 240), 860, 260)
$g.DrawString("Tidak perlu menguasai semua framework dalam seminggu. Memahami fondasi dengan tenang jauh lebih bertahan lama.", $bodyFont, $bodyBrush, $rectB)

$boxPath = New-RoundedRectPath 104 ($y + 540) 872 170 18
$boxBrush = New-Object System.Drawing.SolidBrush((New-Color "#DCE2D7" 100))
$boxPen = New-Object System.Drawing.Pen((New-Color "#6B7B63" 130), 2)
$boxPen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
$g.FillPath($boxBrush, $boxPath)
$g.DrawPath($boxPen, $boxPath)

$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$lblFont = New-Object System.Drawing.Font("Consolas", 16, [System.Drawing.FontStyle]::Regular)
$sageBrush = New-Object System.Drawing.SolidBrush((New-Color "#545D50"))
$qFont = New-Object System.Drawing.Font("Georgia", 24, [System.Drawing.FontStyle]::Italic)
$g.DrawString("OPSIONAL: STIKER POLL / QUESTION BOX", $lblFont, $sageBrush, ($W / 2), ($y + 585), $sfCenter)
$g.DrawString(([char]0x201C + "Buku atau topik apa yang lagi kamu pelajari?" + [char]0x201D), $qFont, $inkBrush, ($W / 2), ($y + 635), $sfCenter)
Save-Canvas $bmp $g "notes-4-reflection.png"
