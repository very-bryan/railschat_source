import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "emojiPicker"]

  connect() {
    // 이모지 피커 외부 클릭 시 닫기
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
  }

  toggleEmojiPicker(event) {
    event.stopPropagation()
    const picker = this.emojiPickerTarget
    picker.classList.toggle("hidden")
    
    if (!picker.classList.contains("hidden")) {
      document.addEventListener("click", this.handleOutsideClick)
    }
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.emojiPickerTarget.classList.add("hidden")
      document.removeEventListener("click", this.handleOutsideClick)
    }
  }

  async addReaction(event) {
    event.preventDefault()
    const emoji = event.currentTarget.dataset.emoji
    const messageId = this.element.id.replace("message-", "")
    
    try {
      const response = await fetch(`/messages/${messageId}/reactions`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        },
        body: JSON.stringify({ emoji: emoji })
      })

      if (response.ok) {
        this.emojiPickerTarget.classList.add("hidden")
      }
    } catch (error) {
      console.error("Error adding reaction:", error)
    }
  }

  async toggleReaction(event) {
    event.preventDefault()
    const emoji = event.currentTarget.dataset.emoji
    const messageId = this.element.id.replace("message-", "")
    
    try {
      const response = await fetch(`/messages/${messageId}/reactions/toggle`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        },
        body: JSON.stringify({ emoji: emoji })
      })
    } catch (error) {
      console.error("Error toggling reaction:", error)
    }
  }

  async replyToMessage(event) {
    event.preventDefault()
    const messageId = this.element.id.replace("message-", "")
    const messageInput = document.querySelector("#new_message textarea, #new_message input[type='text']")
    
    if (messageInput) {
      messageInput.value = `@${this.element.querySelector(".font-semibold").textContent} `
      messageInput.focus()
      messageInput.dataset.replyToId = messageId
    }
  }

  async saveMessage(event) {
    event.preventDefault()
    const messageId = this.element.id.replace("message-", "")
    
    try {
      const response = await fetch(`/messages/${messageId}/save`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        }
      })

      if (response.ok) {
        // 저장 완료 피드백 표시
        this.showToast("메시지가 저장되었습니다")
      }
    } catch (error) {
      console.error("Error saving message:", error)
    }
  }

  async shareMessage(event) {
    event.preventDefault()
    const messageId = this.element.id.replace("message-", "")
    const messageText = this.element.querySelector("p.text-sm").textContent
    
    // 공유 모달 표시 (추후 구현)
    console.log("Share message:", messageId, messageText)
  }

  async pinMessage(event) {
    event.preventDefault()
    const messageId = this.element.id.replace("message-", "")
    
    try {
      const response = await fetch(`/messages/${messageId}/pin`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        }
      })

      if (response.ok) {
        this.showToast("메시지가 상단에 고정되었습니다")
      }
    } catch (error) {
      console.error("Error pinning message:", error)
    }
  }

  showThread(event) {
    event.preventDefault()
    const messageId = this.element.id.replace("message-", "")
    // 스레드 뷰 표시 (추후 구현)
    console.log("Show thread for message:", messageId)
  }

  showToast(message) {
    // 토스트 메시지 표시
    const toast = document.createElement("div")
    toast.className = "fixed bottom-4 right-4 bg-slate-900 text-white px-4 py-2 rounded-lg shadow-lg z-50 animate-fade-in"
    toast.textContent = message
    document.body.appendChild(toast)
    
    setTimeout(() => {
      toast.remove()
    }, 3000)
  }
}