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
$imagePattern = "Image*.jpg"

# Step 1: Find all images
Write-Host "[1/6] Scanning for images..." -ForegroundColor Yellow
$allImages = Get-ChildItem -Path $websiteDir -Filter $imagePattern | 
    Where-Object { $_.Name -match '^Image\d+\.jpg$' } |
    Sort-Object { [int]($_.Name -replace '\D') }

Write-Host "Found $($allImages.Count) total images" -ForegroundColor Green

# Step 2: Check which images are already in HTML
Write-Host "[2/6] Checking HTML file..." -ForegroundColor Yellow
$htmlContent = Get-Content $htmlFile -Raw

$existingImages = @()
foreach ($img in $allImages) {
    if ($htmlContent -match [regex]::Escape($img.Name)) {
        $existingImages += $img.Name
    }
}

Write-Host "Found $($existingImages.Count) images already in HTML" -ForegroundColor Green

# Step 3: Find new images
$newImages = $allImages | Where-Object { $_.Name -notin $existingImages }

if ($newImages.Count -eq 0) {
    Write-Host ""
    Write-Host "✓ No new images found. Your portfolio is up to date!" -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Found $($newImages.Count) NEW IMAGES!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
foreach ($img in $newImages) {
    Write-Host "  • $($img.Name)" -ForegroundColor White
}
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN mode - No changes will be made" -ForegroundColor Yellow
    exit 0
}

# Step 4: Get the next image number
Write-Host "[3/6] Determining image sequence..." -ForegroundColor Yellow
$lastImageNumber = ($existingImages | ForEach-Object {
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
        Write-Host "  Renaming: $($img.Name) → $newName" -ForegroundColor Cyan
        Move-Item -Path $img.FullName -Destination $newPath -Force
        $renamedImages += @{
            OldName = $img.Name
            NewName = $newName
            Number = $currentNumber
            Path = $newPath
        }
    } else {
        $renamedImages += @{
            OldName = $img.Name
            NewName = $newName
            Number = $currentNumber
            Path = $img.FullName
        }
    }
    
    $currentNumber++
}

Write-Host "✓ Images renamed successfully" -ForegroundColor Green
Write-Host ""

# Step 6: Generate AI-powered descriptions
Write-Host "[5/6] Generating descriptions..." -ForegroundColor Yellow
Write-Host "NOTE: Image analysis would require AI vision capabilities." -ForegroundColor Yellow
Write-Host "For now, creating placeholder descriptions that you can customize." -ForegroundColor Yellow
Write-Host ""

# Artistic title templates
$titleThemes = @(
    "Frozen Moment", "Urban Poetry", "Silent Symphony", "Golden Hour", "Ethereal Light",
    "Hidden Geometry", "Whispered Stories", "Timeless Echo", "Dancing Shadows", "Velvet Night",
    "Crystal Dawn", "Sacred Silence", "Wandering Light", "Captured Dream", "Infinite Grace",
    "Serene Chaos", "Painted Sky", "Quiet Majesty", "Mystic Frame", "Gentle Wonder",
    "Fleeting Beauty", "Distant Memories", "Radiant Stillness", "Woven Moments", "Lost in Time"
)

$descriptionTemplates = @(
    "A moment suspended in time, where light and shadow dance in perfect harmony. This frame captures the essence of fleeting beauty frozen forever.",
    "Through the lens, ordinary transforms into extraordinary. Every element conspires to tell a story that words alone cannot express.",
    "In this captured instant, reality meets artistry. The composition speaks to something deeper, a moment that resonates beyond the visible.",
    "Light caresses the scene with gentle grace, revealing details often overlooked. This is where observation becomes meditation.",
    "Here, the mundane transcends into the magical. Each element finds its place in a symphony of visual poetry.",
    "A glimpse into a world both familiar and foreign, where perspective shifts our understanding. This is photography as storytelling.",
    "The camera preserves what the heart remembers. In this frame, emotion and technique merge into something timeless.",
    "Between reality and dreams lies this captured moment. Light, composition, and timing align to create something extraordinary.",
    "Every photograph is a question asked and answered simultaneously. This frame invites contemplation and wonder.",
    "In the quietness of this image, stories unfold. Each viewing reveals new layers, new meanings, new connections."
)

$newDescriptions = @()
foreach ($img in $renamedImages) {
    # Generate unique combinations
    $randomIndex = Get-Random -Maximum $titleThemes.Count
    $title = $titleThemes[$randomIndex] + " " + (Get-Random -Minimum 1 -Maximum 99)
    
    $descIndex = Get-Random -Maximum $descriptionTemplates.Count
    $description = $descriptionTemplates[$descIndex]
    
    $newDescriptions += @{
        Number = $img.Number
        FileName = $img.NewName
        Title = $title
        Description = $description
    }
    
    Write-Host "  Image$($img.Number): $title" -ForegroundColor Cyan
}

# Step 7: Generate HTML for gallery cards
Write-Host ""
Write-Host "[6/6] Updating HTML..." -ForegroundColor Yellow

$galleryHTML = ""
$modalsHTML = ""

foreach ($desc in $newDescriptions) {
    $num = $desc.Number
    $nextNum = if ($num -lt $currentNumber - 1) { $num + 1 } else { 1 }
    
    # Gallery card
    $galleryHTML += @"

                    <a href="#photo-$num" class="photo-card block reveal delay-200">
                        <img src="$($desc.FileName)" alt="Gallery Image" loading="lazy" class="rounded-2xl">
                        <div class="photo-overlay">
                            <button class="view-btn">View</button>
                        </div>
                    </a>
"@

    # Modal overlay
    $modalsHTML += @"

    <div id="photo-$num" class="modal-overlay" style="--bg-img: url('$($desc.FileName)');">
        <a href="#portfolio" class="absolute inset-0 cursor-default"></a>
        <a href="#portfolio" class="absolute top-6 right-6 text-white hover:text-gray-300 z-50"><i
                class="fas fa-times text-4xl"></i></a>
        <a href="#photo-$nextNum"
            class="absolute right-4 text-white hover:text-gray-300 z-50 p-4 bg-black/20 hover:bg-black/50 rounded-full backdrop-blur-sm"><i
                class="fas fa-chevron-right text-3xl"></i></a>

        <div class="modal-text-wrapper">
            <h3 class="text-4xl font-cursive text-white mb-4 border-b border-gray-700 pb-2">$($desc.Title)</h3>
            <p class="text-gray-400 leading-relaxed mb-6">$($desc.Description)</p>
            <div class="flex items-center justify-start pt-2">
                <input type="checkbox" id="like-$num" class="like-checkbox hidden">
                <label for="like-$num"
                    class="flex items-center space-x-2 text-gray-500 cursor-pointer hover:text-gray-300 transition-colors">
                    <i class="far fa-heart text-2xl transition-transform active:scale-90"></i>
                    <span class="text-xs uppercase tracking-widest">Like</span>
                </label>
            </div>
        </div>
        <div class="modal-img-wrapper">
            <img src="$($desc.FileName)" alt="Gallery Image">
        </div>
    </div>
"@
}

# Insert gallery HTML before the closing div of portfolio
$portfolioEndPattern = '</div>\s*</section>\s*<!--\s*Modal Overlays'
if ($htmlContent -match $portfolioEndPattern) {
    $htmlContent = $htmlContent -replace $portfolioEndPattern, "$galleryHTML`r`n                </div>`r`n            </section>`r`n            <!-- Modal Overlays"
}

# Insert modals at the beginning of body
$bodyStartPattern = '<body[^>]*>'
if ($htmlContent -match $bodyStartPattern) {
    $htmlContent = $htmlContent -replace $bodyStartPattern, "$&$modalsHTML"
}

# Update navigation for the last previous photo to point to first new photo
if ($lastImageNumber -gt 0) {
    $findPattern = "(id=`"photo-$lastImageNumber`"[\s\S]*?href=`"#photo-)\d+(`")"
    $htmlContent = $htmlContent -replace $findPattern, "`${1}$($lastImageNumber + 1)`$2"
}

# Save the file
$htmlContent | Set-Content $htmlFile -NoNewline
Write-Host "✓ HTML updated successfully!" -ForegroundColor Green

# Save descriptions to reference file
$descriptionFile = Join-Path $websiteDir "image_descriptions.txt"
$descText = "`r`n`r`n=== NEW IMAGES ADDED $(Get-Date -Format 'yyyy-MM-dd HH:mm') ===`r`n"
foreach ($desc in $newDescriptions) {
    $descText += "`r`nIMAGE $($desc.Number): $($desc.Title)`r`n"
    $descText += "Description: $($desc.Description)`r`n"
}
Add-Content -Path $descriptionFile -Value $descText

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ✓ SUCCESS!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Added $($newDescriptions.Count) new images to your portfolio" -ForegroundColor Green
Write-Host ""

# Git commit
if ($AutoCommit) {
    Write-Host "Committing to Git..." -ForegroundColor Yellow
    git add .
    git commit -m "Auto-add $($newDescriptions.Count) new images to portfolio"
    git push
    Write-Host "✓ Pushed to GitHub!" -ForegroundColor Green
}

Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Review the auto-generated titles and descriptions" -ForegroundColor White
Write-Host "2. Customize them to match each photo's content" -ForegroundColor White  
Write-Host "3. Run 'git add . && git commit && git push' to publish" -ForegroundColor White
Write-Host ""
Write-Host "TIP: You can customize descriptions in image_descriptions.txt" -ForegroundColor Yellow
Write-Host "     then manually update index.html" -ForegroundColor Yellow
Write-Host ""
