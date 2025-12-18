
function resizeGridItem(item) {
    grid = document.getElementsByClassName("grid")[0];
    rowHeight = parseInt(window.getComputedStyle(grid).getPropertyValue('grid-auto-rows'));
    rowGap = parseInt(window.getComputedStyle(grid).getPropertyValue('gap'));
    
    // Get the image height + any padding/border of the card
    // The card has no padding, but has relative positioning.
    // We want the height of the content.
    // The item is the <a> tag .photo-card
    // Its content is the <img>
    
    // We use the image's height directly.
    var img = item.querySelector('img');
    if (!img) return; // safety
    
    // We need the thorough visual height.
    var contentHeight = img.getBoundingClientRect().height;

    // Span = ceil( (contentHeight + gap) / (rowHeight + gap) )
    // Formula derivation: 
    // TotalHeight = span * rowHeight + (span - 1) * gap
    // TotalHeight + gap = span * (rowHeight + gap)
    // span = (TotalHeight + gap) / (rowHeight + gap)
    
    var rowSpan = Math.ceil((contentHeight + rowGap) / (rowHeight + rowGap));
    
    item.style.gridRowEnd = "span " + rowSpan;
}

function resizeAllGridItems() {
    allItems = document.getElementsByClassName("photo-card");
    for (x = 0; x < allItems.length; x++) {
        resizeGridItem(allItems[x]);
    }
}

window.addEventListener("load", resizeAllGridItems);
window.addEventListener("resize", resizeAllGridItems);

// Recalculate as each image loads to avoid overlap
allImages = document.querySelectorAll(".photo-card img");
allImages.forEach(img => {
    if(img.complete) {
        resizeGridItem(img.closest('.photo-card'));
    } else {
        img.addEventListener('load', function() {
            resizeGridItem(img.closest('.photo-card'));
        });
    }
});
