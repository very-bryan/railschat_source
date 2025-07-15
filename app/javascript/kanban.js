// Initialize on multiple events to ensure it works
function initializeKanban() {
  if (!document.querySelector('[data-droppable="true"]')) return;

  let draggedElement = null;
  let placeholder = null;
  let lastValidDropTarget = null;
  let dragStartY = 0;

  // Pan scroll variables
  let isPanning = false;
  let startX = 0;
  let scrollLeft = 0;
  let scrollContainer = null;

  // Initialize drag and drop
  initializeDragAndDrop();
  initializePanScroll();
  initializeCardClicks();

  function initializeDragAndDrop() {
    // Get all draggable elements
    const draggables = document.querySelectorAll('[data-draggable="true"]');
    const droppables = document.querySelectorAll('[data-droppable="true"]');

    // Add event listeners to draggable elements
    draggables.forEach(draggable => {
      draggable.addEventListener('dragstart', handleDragStart);
      draggable.addEventListener('dragend', handleDragEnd);
    });

    // Add event listeners to droppable areas
    droppables.forEach(droppable => {
      droppable.addEventListener('dragover', handleDragOver);
      droppable.addEventListener('drop', handleDrop);
      droppable.addEventListener('dragleave', handleDragLeave);
    });
  }

  function handleDragStart(e) {
    // Find the card element (with data-draggable)
    draggedElement = e.target.closest('[data-draggable="true"]');
    if (!draggedElement) return;
    
    dragStartY = e.clientY;
    
    // Create placeholder
    placeholder = document.createElement('div');
    placeholder.className = 'bg-[#FFE0E2] rounded-md border-2 border-dashed border-[#FFB3BA] transition-all';
    placeholder.style.height = draggedElement.offsetHeight + 'px';
    placeholder.style.marginBottom = window.getComputedStyle(draggedElement).marginBottom;
    
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/html', draggedElement.innerHTML);
    
    // Store the original parent
    draggedElement.originalParent = draggedElement.parentElement;
    draggedElement.originalNextSibling = draggedElement.nextSibling;
    
    // Add dragging class after a small delay to prevent visual glitch
    setTimeout(() => {
      draggedElement.classList.add('opacity-50', 'dragging');
      // Insert placeholder at original position
      draggedElement.parentElement.insertBefore(placeholder, draggedElement.nextSibling);
    }, 0);
  }

  function handleDragOver(e) {
    if (e.preventDefault) {
      e.preventDefault();
    }
    
    e.dataTransfer.dropEffect = 'move';
    
    const container = e.currentTarget;
    const mouseY = e.clientY;
    
    // Calculate overlap percentage based on mouse position and container bounds
    const containerRect = container.getBoundingClientRect();
    const draggedRect = draggedElement.getBoundingClientRect();
    
    // Calculate the theoretical position of the dragged element based on mouse position
    const draggedTop = mouseY - (dragStartY - draggedRect.top);
    const draggedBottom = draggedTop + draggedRect.height;
    
    // Calculate overlap with container
    const overlapTop = Math.max(containerRect.top, draggedTop);
    const overlapBottom = Math.min(containerRect.bottom, draggedBottom);
    const overlapHeight = Math.max(0, overlapBottom - overlapTop);
    const overlapPercentage = (overlapHeight / draggedRect.height) * 100;
    
    // Also check if mouse is within the horizontal bounds and below the container top
    const mouseX = e.clientX;
    const isWithinHorizontalBounds = mouseX >= containerRect.left && mouseX <= containerRect.right;
    const isMouseBelowTop = mouseY >= containerRect.top;
    
    // Allow drop if 50% overlap OR if mouse is within column bounds and below top
    if (overlapPercentage >= 50 || (isWithinHorizontalBounds && isMouseBelowTop)) {
      container.classList.add('ring-2', 'ring-[#FF9EA6]');
      lastValidDropTarget = container;
      
      // Find the best position for the placeholder
      const afterElement = getDragAfterElement(container, mouseY);
      
      if (!container.contains(placeholder)) {
        // Moving to a different column
        if (afterElement == null) {
          container.appendChild(placeholder);
        } else {
          container.insertBefore(placeholder, afterElement);
        }
      } else {
        // Moving within the same column
        if (afterElement == null) {
          container.appendChild(placeholder);
        } else if (afterElement !== placeholder && afterElement !== placeholder.nextSibling) {
          container.insertBefore(placeholder, afterElement);
        }
      }
    } else {
      container.classList.remove('ring-2', 'ring-[#FF9EA6]');
      if (lastValidDropTarget === container) {
        lastValidDropTarget = null;
      }
    }
    
    return false;
  }

  function handleDrop(e) {
    if (e.stopPropagation) {
      e.stopPropagation();
    }
    
    const container = e.currentTarget;
    container.classList.remove('ring-2', 'ring-[#FF9EA6]');
    
    if (lastValidDropTarget !== container) {
      // Not a valid drop target
      return false;
    }
    
    const noteId = draggedElement.dataset.noteId;
    const statusId = container.dataset.statusId;
    const oldStatusId = draggedElement.originalParent.dataset.statusId;
    
    // Calculate the final position
    const allCards = Array.from(container.querySelectorAll('[data-draggable="true"]'));
    const placeholderIndex = Array.from(container.children).indexOf(placeholder);
    
    // Replace placeholder with the dragged element
    if (placeholder.parentNode === container) {
      container.replaceChild(draggedElement, placeholder);
    }
    
    // Only send update if position or status changed
    if (statusId !== oldStatusId || draggedElement.parentElement !== draggedElement.originalParent || 
        draggedElement.nextSibling !== draggedElement.originalNextSibling) {
      updateNoteStatus(noteId, statusId, placeholderIndex);
    }
    
    return false;
  }

  function handleDragEnd(e) {
    if (draggedElement) {
      // Clean up
      draggedElement.classList.remove('opacity-50', 'dragging');
      draggedElement.style.display = '';
    }
    
    // Remove all visual feedback
    document.querySelectorAll('[data-droppable="true"]').forEach(droppable => {
      droppable.classList.remove('ring-2', 'ring-[#FF9EA6]');
    });
    
    // Remove placeholder if it still exists
    if (placeholder && placeholder.parentNode) {
      placeholder.parentNode.removeChild(placeholder);
    }
    
    // Reset variables
    draggedElement = null;
    placeholder = null;
    lastValidDropTarget = null;
    dragStartY = 0;
  }

  function handleDragLeave(e) {
    // Only remove styles if we're actually leaving the container
    const container = e.currentTarget;
    const relatedTarget = e.relatedTarget;
    
    if (!container.contains(relatedTarget)) {
      container.classList.remove('ring-2', 'ring-[#FF9EA6]');
    }
  }

  function getDragAfterElement(container, y) {
    const draggableElements = [...container.querySelectorAll('[data-draggable="true"]:not(.opacity-50)')];
    
    return draggableElements.reduce((closest, child) => {
      const box = child.getBoundingClientRect();
      const offset = y - box.top - box.height / 2;
      
      if (offset < 0 && offset > closest.offset) {
        return { offset: offset, element: child };
      } else {
        return closest;
      }
    }, { offset: Number.NEGATIVE_INFINITY }).element;
  }

  function updateNoteStatus(noteId, statusId, position) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    
    // Show loading state
    showNotification('저장 중...', 'info');
    
    fetch('/kanban/update_status', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({
        note_id: noteId,
        status_id: statusId,
        position: position
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        showNotification('노트가 이동되었습니다.', 'success');
      } else {
        showNotification('이동에 실패했습니다: ' + data.error, 'error');
        // Reload to restore original state
        setTimeout(() => window.location.reload(), 1000);
      }
    })
    .catch(error => {
      console.error('Error:', error);
      showNotification('오류가 발생했습니다.', 'error');
      setTimeout(() => window.location.reload(), 1000);
    });
  }

  function showNotification(message, type) {
    // Remove any existing notifications
    const existingNotification = document.querySelector('.kanban-notification');
    if (existingNotification) {
      existingNotification.remove();
    }
    
    const notification = document.createElement('div');
    const bgColor = type === 'success' ? 'bg-emerald-500' : type === 'error' ? 'bg-red-500' : 'bg-[#FF8A92]';
    notification.className = `kanban-notification fixed top-4 right-4 ${bgColor} text-white px-4 py-2 rounded-lg shadow-lg z-50 transition-opacity duration-300`;
    notification.textContent = message;
    document.body.appendChild(notification);
    
    if (type !== 'error') {
      setTimeout(() => {
        notification.style.opacity = '0';
        setTimeout(() => {
          notification.remove();
        }, 300);
      }, 2000);
    }
  }

  function initializePanScroll() {
    scrollContainer = document.querySelector('.kanban-scroll-container');
    if (!scrollContainer) return;

    // Add cursor style
    scrollContainer.style.cursor = 'grab';

    scrollContainer.addEventListener('mousedown', handlePanStart);
    scrollContainer.addEventListener('mousemove', handlePanMove);
    scrollContainer.addEventListener('mouseup', handlePanEnd);
    scrollContainer.addEventListener('mouseleave', handlePanEnd);
  }

  function handlePanStart(e) {
    // Check if clicking on empty space (not on a card or droppable area content)
    if (e.target.closest('[data-draggable="true"]') || 
        e.target.closest('a') || 
        e.target.closest('button')) {
      return;
    }

    isPanning = true;
    startX = e.pageX - scrollContainer.offsetLeft;
    scrollLeft = scrollContainer.scrollLeft;
    scrollContainer.style.cursor = 'grabbing';
    scrollContainer.style.userSelect = 'none';
    
    // Prevent default to avoid text selection
    e.preventDefault();
  }

  function handlePanMove(e) {
    if (!isPanning) return;
    
    e.preventDefault();
    const x = e.pageX - scrollContainer.offsetLeft;
    const walk = (x - startX) * 1.5; // Multiply by 1.5 for faster scrolling
    scrollContainer.scrollLeft = scrollLeft - walk;
  }

  function handlePanEnd() {
    if (!isPanning) return;
    
    isPanning = false;
    scrollContainer.style.cursor = 'grab';
    scrollContainer.style.userSelect = '';
  }

  function initializeCardClicks() {
    const cards = document.querySelectorAll('[data-draggable="true"]');
    
    cards.forEach(card => {
      let isDragging = false;
      let clickStartX = 0;
      let clickStartY = 0;
      
      card.addEventListener('mousedown', (e) => {
        clickStartX = e.clientX;
        clickStartY = e.clientY;
        isDragging = false;
      });
      
      card.addEventListener('mousemove', (e) => {
        const moveX = Math.abs(e.clientX - clickStartX);
        const moveY = Math.abs(e.clientY - clickStartY);
        
        // If mouse moved more than 5 pixels, consider it dragging
        if (moveX > 5 || moveY > 5) {
          isDragging = true;
        }
      });
      
      card.addEventListener('click', (e) => {
        // Prevent click if dragging or clicking on action buttons
        if (isDragging || e.target.closest('a') || e.target.closest('button')) {
          return;
        }
        
        // Get note ID and navigate
        const noteId = card.dataset.noteId;
        if (noteId) {
          window.location.href = `/notes/${noteId}`;
        }
      });
    });
  }
}

// Initialize on multiple events to ensure it works
document.addEventListener('DOMContentLoaded', initializeKanban);
document.addEventListener('turbo:load', initializeKanban);
document.addEventListener('turbo:render', initializeKanban);

// Also initialize if already loaded
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeKanban);
} else {
  initializeKanban();
}