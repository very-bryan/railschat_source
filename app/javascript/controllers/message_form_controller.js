import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["attachmentMenu", "fileInput", "attachmentPreview", "attachmentList", "attachedNoteId", "parentMessageId", "body"]

  connect() {
    // Close attachment menu when clicking outside
    document.addEventListener('click', this.handleOutsideClick.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target) && this.hasAttachmentMenuTarget && !this.attachmentMenuTarget.classList.contains('hidden')) {
      this.attachmentMenuTarget.classList.add('hidden')
    }
  }

  toggleAttachmentMenu(event) {
    event.stopPropagation()
    if (this.hasAttachmentMenuTarget) {
      this.attachmentMenuTarget.classList.toggle('hidden')
    }
  }

  attachFiles() {
    if (this.hasAttachmentMenuTarget) {
      this.attachmentMenuTarget.classList.add('hidden')
    }
    if (this.hasFileInputTarget) {
      this.fileInputTarget.click()
    }
  }

  handleFileSelect() {
    if (!this.hasFileInputTarget) return
    const files = Array.from(this.fileInputTarget.files)
    if (files.length > 0 && this.hasAttachmentPreviewTarget && this.hasAttachmentListTarget) {
      // Clear existing previews
      this.attachmentListTarget.innerHTML = ''
      
      files.forEach(file => {
        const item = document.createElement('div')
        item.className = 'flex items-center gap-2 text-xs'
        
        const icon = document.createElement('span')
        icon.innerHTML = this.getFileIcon(file.type)
        
        const name = document.createElement('span')
        name.className = 'text-slate-600 truncate'
        name.textContent = file.name
        
        item.appendChild(icon)
        item.appendChild(name)
        this.attachmentListTarget.appendChild(item)
      })
      
      this.attachmentPreviewTarget.classList.remove('hidden')
    }
  }

  clearAttachments() {
    if (this.hasFileInputTarget) {
      this.fileInputTarget.value = ''
    }
    if (this.hasAttachedNoteIdTarget) {
      this.attachedNoteIdTarget.value = ''
    }
    if (this.hasAttachmentPreviewTarget) {
      this.attachmentPreviewTarget.classList.add('hidden')
    }
    if (this.hasAttachmentListTarget) {
      this.attachmentListTarget.innerHTML = ''
    }
  }

  attachNote() {
    if (this.hasAttachmentMenuTarget) {
      this.attachmentMenuTarget.classList.add('hidden')
    }
    
    // Open note selector modal
    const modal = document.createElement('div')
    modal.className = 'fixed inset-0 z-50 flex items-center justify-center'
    modal.style.backgroundColor = 'rgba(0, 0, 0, 0.5)'
    modal.innerHTML = `
      <div class="bg-white rounded-lg shadow-xl w-full max-w-2xl mx-4 max-h-[80vh] overflow-hidden">
        <div class="border-b border-slate-200 p-4">
          <h3 class="text-lg font-semibold text-slate-900">노트 선택</h3>
        </div>
        <div class="p-4 max-h-[60vh] overflow-y-auto">
          <div class="text-center py-8 text-slate-500">
            <svg class="w-12 h-12 mx-auto mb-3 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
            </svg>
            <p>노트를 불러오는 중...</p>
          </div>
        </div>
        <div class="border-t border-slate-200 p-4 flex justify-end">
          <button type="button" class="px-4 py-2 text-sm font-medium text-slate-700 hover:text-slate-900">
            취소
          </button>
        </div>
      </div>
    `
    
    // Close modal when clicking outside or cancel button
    modal.addEventListener('click', (e) => {
      if (e.target === modal || e.target.textContent === '취소') {
        modal.remove()
      }
    })
    
    document.body.appendChild(modal)
    
    // Fetch notes
    fetch('/notes.json', {
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
      .then(response => response.json())
      .then(data => {
        const contentDiv = modal.querySelector('.p-4.max-h-\\[60vh\\]')
        // The response is likely an array directly, not an object with notes property
        const notes = Array.isArray(data) ? data : (data.notes || [])
        if (notes.length > 0) {
          contentDiv.innerHTML = notes.map(note => `
            <div class="p-3 border border-slate-200 rounded-md mb-2 cursor-pointer hover:bg-slate-50" 
                 onclick="selectNote(${note.id}, '${note.title.replace(/'/g, "\\'")}')">
              <h4 class="font-medium text-slate-900">${note.title}</h4>
              ${note.content ? `<p class="text-sm text-slate-600 mt-1">${note.content.substring(0, 100)}...</p>` : ''}
            </div>
          `).join('')
        } else {
          contentDiv.innerHTML = '<p class="text-center text-slate-500">노트가 없습니다.</p>'
        }
      })
      .catch(error => {
        console.error('Failed to load notes:', error)
        const contentDiv = modal.querySelector('.p-4.max-h-\\[60vh\\]')
        contentDiv.innerHTML = '<p class="text-center text-red-500">노트를 불러오는데 실패했습니다.</p>'
      })
    
    // Make selectNote function available globally for the onclick handler
    const controller = this
    window.selectNote = (noteId, noteTitle) => {
      if (controller.hasAttachedNoteIdTarget) {
        controller.attachedNoteIdTarget.value = noteId
      }
      
      // Show attachment preview
      if (controller.hasAttachmentPreviewTarget && controller.hasAttachmentListTarget) {
        controller.attachmentListTarget.innerHTML = `
          <div class="flex items-center gap-2 text-xs">
            <svg class="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
            </svg>
            <span class="text-slate-600 truncate">${noteTitle}</span>
          </div>
        `
        controller.attachmentPreviewTarget.classList.remove('hidden')
      }
      
      modal.remove()
      delete window.selectNote
    }
  }

  handleKeyPress(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault()
      const form = this.element.querySelector('form')
      if (form) {
        // Find the submit button and click it to trigger form submission
        const submitButton = form.querySelector('button[type="submit"]')
        if (submitButton) {
          submitButton.click()
        }
      }
    }
  }

  getFileIcon(type) {
    if (type.startsWith('image/')) {
      return '<svg class="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>'
    } else if (type.includes('pdf')) {
      return '<svg class="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path></svg>'
    } else {
      return '<svg class="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>'
    }
  }
}