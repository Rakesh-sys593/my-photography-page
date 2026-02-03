#!/usr/bin/env pwsh
# Auto Image Upload & Description Generator
# This script automatically detects new images, generates descriptions, and updates your portfolio

param(
    [switch]$AutoCommit = $false,
    [switch]$DryRun = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Auto Image Upload & Description Tool" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""


# Configuration
$websiteDir = "d:\my website"
$htmlFile = Join-Path $websiteDir "index.html"


# Step 1: Find all images
Write-Host "[1/6] Scanning for images..." -ForegroundColor Yellow
# Get all JPG files in the directory
$allJpgFiles = Get-ChildItem -Path $websiteDir -Filter "*.jpg"

# Identify images that are already in the 'ImageN.jpg' format
$formattedImages = $allJpgFiles | Where-Object { $_.Name -match '^Image\d+\.jpg$' } |
Sort-Object { [int]($_.Name -replace '\D') }

Write-Host "Found $($formattedImages.Count) images in 'ImageN.jpg' format" -ForegroundColor Green

# Step 2: Check which formatted images are already in HTML
Write-Host "[2/6] Checking HTML file..." -ForegroundColor Yellow
$htmlContent = Get-Content $htmlFile -Raw

$existingImagesInHtml = @()
foreach ($img in $formattedImages) {
    if ($htmlContent -match [regex]::Escape($img.Name)) {
        $existingImagesInHtml += $img.Name
    }
}

Write-Host "Found $($existingImagesInHtml.Count) 'ImageN.jpg' files already in HTML" -ForegroundColor Green

# Step 3: Find new images (those not in 'ImageN.jpg' format or 'ImageN.jpg' not yet in HTML)
# First, find unformatted images that need to be renamed (excluding profile image)
$unformattedNewImages = $allJpgFiles | Where-Object { 
    $_.Name -notmatch '^Image\d+\.jpg$' -and 
    $_.Name -ne 'image.jpg' 
}

# Then, find formatted images that are not yet in HTML
$formattedNewImages = $formattedImages | Where-Object { $_.Name -notin $existingImagesInHtml }

# Combine them to get all images that need processing
$newImages = @($unformattedNewImages) + @($formattedNewImages)

if ($newImages.Count -eq 0) {
    Write-Host ""
    Write-Host "No new images found. Your portfolio is up to date!" -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Found $($newImages.Count) NEW IMAGES!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
foreach ($img in $newImages) {
    Write-Host "  - $($img.Name)" -ForegroundColor White
}
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN mode - No changes will be made" -ForegroundColor Yellow
    exit 0
}

# Step 4: Get the next image number
Write-Host "[3/6] Determining image sequence..." -ForegroundColor Yellow
$lastImageNumber = ($existingImagesInHtml | ForEach-Object {
        [int]($_ -replace '\D')
    } | Measure-Object -Maximum).Maximum

Write-Host "Last image in portfolio: Image$lastImageNumber.jpg" -ForegroundColor Green

# Step 5: Rename new images sequentially
Write-Host "[4/6] Renaming new images..." -ForegroundColor Yellow
$renamedImages = @()
$currentNumber = $lastImageNumber + 1

foreach ($img in $newImages) {
    $newName = "Image$currentNumber.jpg"
    $newPath = Join-Path $websiteDir $newName
    
    # Only rename if not already in correct format
    if ($img.Name -ne $newName) {
        Write-Host "  Renaming: $($img.Name) -> $newName" -ForegroundColor Cyan
        Move-Item -Path $img.FullName -Destination $newPath -Force
        $renamedImages += @{
            OldName = $img.Name
            NewName = $newName
            Number  = $currentNumber
            Path    = $newPath
        }
    }
    else {
        $renamedImages += @{
            OldName = $img.Name
            NewName = $newName
            Number  = $currentNumber
            Path    = $img.FullName
        }
    }
    
    $currentNumber++
}

Write-Host "Images renamed successfully" -ForegroundColor Green
Write-Host ""

# Step 6: Generate AI-powered descriptions
Write-Host "[5/6] Generating placeholder descriptions..." -ForegroundColor Yellow
Write-Host "NOTE: These are generic placeholders." -ForegroundColor Yellow
Write-Host "Ask your AI assistant to analyze and create unique descriptions!" -ForegroundColor Yellow
Write-Host ""

# Artistic title templates
$titleThemes = @(
    "Frozen Moment", "Urban Poetry", "Silent Symphony", "Golden Hour", "Ethereal Light",
    "Hidden Geometry", "Whispered Stories", "Timeless Echo", "Dancing Shadows", "Velvet Night"
)

$descriptionTemplates = @(
    "A moment suspended in time, where light and shadow dance together. This frame captures fleeting beauty frozen forever.",
    "Through the lens, ordinary transforms into extraordinary. Every element conspires to tell its unique story.",
    "In this captured instant, reality meets artistry. The composition speaks to something deeper and timeless.",
    "Light caresses the scene with gentle grace. This is where observation becomes meditation and art.",
    "Here, the mundane transcends into the magical. Each element finds its place in visual poetry."
)

$newDescriptions = @()
foreach ($img in $renamedImages) {
    $randomIndex = Get-Random -Maximum $titleThemes.Count
    $title = $titleThemes[$randomIndex] + " " + (Get-Random -Minimum 1 -Maximum 99)
    
    $descIndex = Get-Random -Maximum $descriptionTemplates.Count
    $description = $descriptionTemplates[$descIndex]
    
    $newDescriptions += @{
        Number      = $img.Number
        FileName    = $img.NewName
        Title       = $title
        Description = $description
    }
    
    Write-Host "  Image$($img.Number): $title" -ForegroundColor Cyan
}

# Step 7: Generate HTML
Write-Host ""
Write-Host "[6/6] Updating HTML..." -ForegroundColor Yellow

$galleryHTML = ""
$modalsHTML = ""

foreach ($desc in $newDescriptions) {
    $num = $desc.Number
    $nextNum = if ($num -lt $currentNumber - 1) { $num + 1 } else { 1 }
    
    # Gallery card
    $galleryHTML += "`r`n                    <a href=`"#photo-$num`" class=`"photo-card block reveal delay-200`">`r`n"
    $galleryHTML += "                        <img src=`"$($desc.FileName)`" alt=`"Gallery Image`" loading=`"lazy`" class=`"rounded-2xl`">`r`n"
    $galleryHTML += "                        <div class=`"photo-overlay`">`r`n"
    $galleryHTML += "                            <button class=`"view-btn`">View</button>`r`n"
    $galleryHTML += "                        </div>`r`n"
    $galleryHTML += "                    </a>"

    # Modal overlay
    $modalsHTML += "`r`n    <div id=`"photo-$num`" class=`"modal-overlay`" style=`"--bg-img: url('$($desc.FileName)');`">`r`n"
    $modalsHTML += "        <a href=`"#portfolio`" class=`"absolute inset-0 cursor-default`"></a>`r`n"
    $modalsHTML += "        <a href=`"#portfolio`" class=`"absolute top-6 right-6 text-white hover:text-gray-300 z-50`"><i class=`"fas fa-times text-4xl`"></i></a>`r`n"
    $modalsHTML += "        <a href=`"#photo-$nextNum`" class=`"absolute right-4 text-white hover:text-gray-300 z-50 p-4 bg-black/20 hover:bg-black/50 rounded-full backdrop-blur-sm`"><i class=`"fas fa-chevron-right text-3xl`"></i></a>`r`n"
    $modalsHTML += "        <div class=`"modal-text-wrapper`">`r`n"
    $modalsHTML += "            <h3 class=`"text-4xl font-cursive text-white mb-4 border-b border-gray-700 pb-2`">$($desc.Title)</h3>`r`n"
    $modalsHTML += "            <p class=`"text-gray-400 leading-relaxed mb-6`">$($desc.Description)</p>`r`n"
    $modalsHTML += "            <div class=`"flex items-center justify-start pt-2`">`r`n"
    $modalsHTML += "                <input type=`"checkbox`" id=`"like-$num`" class=`"like-checkbox hidden`">`r`n"
    $modalsHTML += "                <label for=`"like-$num`" class=`"flex items-center space-x-2 text-gray-500 cursor-pointer hover:text-gray-300 transition-colors`">`r`n"
    $modalsHTML += "                    <i class=`"far fa-heart text-2xl transition-transform active:scale-90`"></i>`r`n"
    $modalsHTML += "                    <span class=`"text-xs uppercase tracking-widest`">Like</span>`r`n"
    $modalsHTML += "                </label>`r`n"
    $modalsHTML += "            </div>`r`n"
    $modalsHTML += "        </div>`r`n"
    $modalsHTML += "        <div class=`"modal-img-wrapper`">`r`n"
    $modalsHTML += "            <img src=`"$($desc.FileName)`" alt=`"Gallery Image`">`r`n"
    $modalsHTML += "        </div>`r`n"
    $modalsHTML += "    </div>"
}

# Insert gallery HTML
$portfolioEndPattern = '</div>\s*</section>\s*<!--\s*Modal Overlays'
if ($htmlContent -match $portfolioEndPattern) {
    $htmlContent = $htmlContent -replace $portfolioEndPattern, "$galleryHTML`r`n                </div>`r`n            </section>`r`n            <!-- Modal Overlays"
}

# Insert modals at beginning of body
$bodyStartPattern = '<body[^>]*>'
if ($htmlContent -match $bodyStartPattern) {
    $htmlContent = $htmlContent -replace $bodyStartPattern, "$&$modalsHTML"
}

# Update navigation
if ($lastImageNumber -gt 0) {
    $findPattern = "(id=`"photo-$lastImageNumber`"[\s\S]*?href=`"#photo-)\d+(`")"
    $htmlContent = $htmlContent -replace $findPattern, "`${1}$($lastImageNumber + 1)`$2"
}

# Save the file
$htmlContent | Set-Content $htmlFile -NoNewline
Write-Host "HTML updated successfully!" -ForegroundColor Green

# Save descriptions
$descriptionFile = Join-Path $websiteDir "image_descriptions.txt"
$descText = "`r`n`r`n=== NEW IMAGES ADDED $(Get-Date -Format 'yyyy-MM-dd HH:mm') ===`r`n"
foreach ($desc in $newDescriptions) {
    $descText += "`r`nIMAGE $($desc.Number): $($desc.Title)`r`n"
    $descText += "Description: $($desc.Description)`r`n"
}
Add-Content -Path $descriptionFile -Value $descText

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  SUCCESS!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Added $($newDescriptions.Count) new images to your portfolio" -ForegroundColor Green
Write-Host ""

# Git commit
if ($AutoCommit) {
    Write-Host "Committing to Git..." -ForegroundColor Yellow
    git add .
    git commit -m "Auto-add $($newDescriptions.Count) new images to portfolio"
    git push
    Write-Host "Pushed to GitHub!" -ForegroundColor Green
}

Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Review the auto-generated placeholder descriptions" -ForegroundColor White
Write-Host "2. Ask your AI assistant to analyze the images" -ForegroundColor White  
Write-Host "3. Run git commands to publish your changes" -ForegroundColor White
Write-Host ""
