# 📸 Automated Image Upload System

## Overview
This automation system helps you quickly add new images to your photography portfolio website. It automatically detects new images, renames them sequentially, generates placeholder descriptions, and updates your HTML.

## 🚀 Quick Start

### Basic Usage
Simply drop new images into your website folder, then run:

```powershell
.\auto_add_images.ps1
```

### With Auto Git Commit
To automatically commit and push changes to GitHub:

```powershell
.\auto_add_images.ps1 -AutoCommit
```

### Dry Run (Preview Only)
To see what would happen without making changes:

```powershell
.\auto_add_images.ps1 -DryRun
```

## ✨ What It Does

1. **Scans for New Images** - Detects any new JPG files in your website directory
2. **Sequential Renaming** - Automatically renames images to Image[N].jpg format
3. **Generates Descriptions** - Creates artistic placeholder titles and descriptions
4. **Updates HTML** - Adds gallery cards and modal overlays automatically
5. **Updates Navigation** - Links all photos in a carousel
6. **Git Integration** - Optionally commits and pushes changes

## 📋 Workflow

### Standard Workflow:
1. Copy your new photos to `d:\my website\`
2. Run `.\auto_add_images.ps1`
3. Review the auto-generated descriptions
4. Customize titles/descriptions if needed (manual editing recommended for best results)
5. Commit: `git add . && git commit -m "Add new photos" && git push`

### Quick Workflow (Auto-commit):
1. Copy photos to website folder
2. Run `.\auto_add_images.ps1 -AutoCommit`
3. Done! ✓

## 🎨 Customizing Descriptions

The script generates placeholder descriptions using artistic templates. For BEST results:

### Method 1: Ask AI to Analyze (Recommended)
After running the script, ask your AI assistant:
```
"Can you analyze the newly added images and write poetic descriptions?"
```

The AI will:
- View each new image
- Understand its content and mood
- Generate unique, tailored descriptions
- Update your HTML automatically

### Method 2: Manual Editing
1. Open `image_descriptions.txt` to see all descriptions
2. Edit titles and descriptions in `index.html`
3. Find each modal by searching for `id="photo-[N]"`
4. Update the `<h3>` (title) and `<p>` (description) tags

## 🔧 Script Options

| Option | Description |
|--------|-------------|
| `-AutoCommit` | Automatically run git add, commit, and push |
| `-DryRun` | Preview what would happen without making changes |

## 📁 Files Modified

- `index.html` - Gallery and modal sections updated
- `image_descriptions.txt` - Log of all descriptions (append-only)

## ⚙️ Technical Details

### Image Detection
- Matches pattern: `Image*.jpg`
- Filters to: `Image[number].jpg` format only
- Sorts numerically

### Naming Convention
- Format: `ImageXX.jpg` where XX is a sequential number
- Continues from the last image number in HTML
- Example: If last image is Image51.jpg, next will be Image52.jpg

### HTML Insertion Points
- **Gallery Cards**: Added before `</section>` in portfolio section
- **Modals**: Inserted at the beginning of `<body>`
- **Navigation**: Last photo links to first new photo

## 🎯 Best Practices

1. **Backup First**: Always commit your current work before running automation
2. **Review Output**: Check the generated HTML for accuracy
3. **Customize Descriptions**: Use AI or manual editing for personalized content
4. **Test Locally**: Open index.html in browser to verify
5. **Commit Frequently**: Keep your Git history clean with regular commits

## 🐛 Troubleshooting

### "Running scripts is disabled"
Run with execution policy bypass:
```powershell
powershell -ExecutionPolicy Bypass -File .\auto_add_images.ps1
```

### Images not detected
- Ensure images are in `d:\my website\` directory
- Check that filenames don't already exist in HTML
- Verify images are `.jpg` format

### HTML not updating correctly
- Check that your HTML structure matches the expected format
- Ensure you haven't modified the portfolio or modal sections significantly
- Review the console output for errors

## 📝 Example Output

```
========================================
  Auto Image Upload & Description Tool
========================================

[1/6] Scanning for images...
Found 54 total images

[2/6] Checking HTML file...
Found 51 images already in HTML

========================================
  Found 3 NEW IMAGES!
========================================
  • DSC_1234.jpg
  • DSC_1235.jpg
  • DSC_1236.jpg

[3/6] Determining image sequence...
Last image in portfolio: Image51.jpg

[4/6] Renaming new images...
  Renaming: DSC_1234.jpg → Image52.jpg
  Renaming: DSC_1235.jpg → Image53.jpg
  Renaming: DSC_1236.jpg → Image54.jpg
✓ Images renamed successfully

[5/6] Generating descriptions...
  Image52: Frozen Moment 42
  Image53: Urban Poetry 17
  Image54: Golden Hour 88

[6/6] Updating HTML...
✓ HTML updated successfully!

========================================
  ✓ SUCCESS!
========================================
Added 3 new images to your portfolio
```

## 🎨 For Maximum Impact

After running the automation, enhance your descriptions:

1. **Use AI Analysis**: 
   - Let AI view each photo
   - Get contextual, poetic descriptions
   - Much better than templates!

2. **Manual Refinement**:
   - Add specific details about location
   - Include technical details (camera, lens, etc.)
   - Share the story behind the shot

## 📞 Support

If you encounter issues:
1. Check this README
2. Review the console output
3. Verify your HTML structure
4. Ask your AI assistant for help!

---

**Happy photographing! 📸✨**
