document.addEventListener('DOMContentLoaded', function() {

  // --- CONFIGURATION ---
  // Set this to the height of your sticky header + padding (in pixels)
  // 80 is a good starting point (e.g., 70px header + 10px padding)
  const SCROLL_OFFSET_PX = 40;
  // --- END CONFIGURATION ---

  // Function to get all section headings (h2 and h3) in order
  function getSections() {
    const content = document.querySelector('.quarto-body-content') || document.querySelector('main');
    if (!content) {
      console.warn("Quarto Nav: Could not find main content area ('.quarto-body-content' or 'main').");
      return [];
    }
    const sections = content.querySelectorAll('h2, h3, h4');
    return Array.from(sections);
  }

  // Function to find the index of the section currently or most recently at the top
  function findCurrentSectionIndex(sections) {
    let currentIndex = -1;
    // Add a small offset (e.g., 80px, matching our offset)
    const scrollPosition = window.scrollY + SCROLL_OFFSET_PX; 

    for (let i = 0; i < sections.length; i++) {
      if (sections[i].offsetTop <= scrollPosition) {
        currentIndex = i;
      } else {
        break;
      }
    }
    return currentIndex;
  }

  // --- Main Keydown Listener ---
  document.addEventListener('keydown', function(e) {
    
    var tagName = e.target.tagName.toLowerCase();
    if (tagName === 'input' || tagName === 'textarea' || e.target.closest('.quarto-code-cell')) {
      return;
    }
    
    if (e.key !== "ArrowRight" && e.key !== "ArrowLeft") {
        return;
    }
    
    const sections = getSections();
    e.preventDefault(); 

    if (sections.length === 0) {
      console.log("Quarto Nav: No sections (h2 or h3) found on this page.");
      return;
    }
    
    const currentIndex = findCurrentSectionIndex(sections);

    // --- Right Arrow: Go to next section ---
    if (e.key === "ArrowRight") {
      const nextIndex = currentIndex + 1;
      
      if (nextIndex < sections.length) {
        console.log("Quarto Nav: Moving to next section", sections[nextIndex]);
        
        // --- MODIFIED LINES ---
        // Calculate position: section's top - offset
        let targetPosition = sections[nextIndex].offsetTop - SCROLL_OFFSET_PX;
        // Ensure we don't scroll to a negative position
        targetPosition = Math.max(0, targetPosition);
        window.scrollTo({ top: targetPosition, behavior: 'instant' });
        // --- END MODIFIED LINES ---

      } else {
        console.log("Quarto Nav: Already at last section.");
      }
    } 
    // --- Left Arrow: Go to previous section ---
    else if (e.key === "ArrowLeft") {
      if (currentIndex > 0) {
        console.log("Quarto Nav: Moving to previous section", sections[currentIndex - 1]);
        
        // --- MODIFIED LINES ---
        // Calculate position: section's top - offset
        let targetPosition = sections[currentIndex - 1].offsetTop - SCROLL_OFFSET_PX;
        // Ensure we don't scroll to a negative position
        targetPosition = Math.max(0, targetPosition);
        window.scrollTo({ top: targetPosition, behavior: 'instant' });
        // --- END MODIFIED LINES ---

      } else if (currentIndex === 0) {
         // If at the first section, scroll to the top of the page (no offset)
         console.log("Quarto Nav: Moving to page top.");
        window.scrollTo({ top: 0, behavior: 'smooth' });
      } else {
        console.log("Quarto Nav: Already at page top (or above first section).");
      }
    }
  });
});
