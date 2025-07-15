import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["viewers"]
  static values = { noteId: Number }

  connect() {
    this.subscription = consumer.subscriptions.create(
      { 
        channel: "NotePresenceChannel",
        note_id: this.noteIdValue
      },
      {
        connected: () => {
          console.log("Connected to NotePresenceChannel")
        },

        disconnected: () => {
          console.log("Disconnected from NotePresenceChannel")
        },

        received: (data) => {
          this.updateViewers(data.viewers)
        }
      }
    )
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  updateViewers(viewers) {
    if (!this.hasViewersTarget) return

    const viewersList = viewers.filter(v => v.id !== currentUserId)
    
    if (viewersList.length === 0) {
      this.viewersTarget.innerHTML = ""
      return
    }

    const html = viewersList.map(viewer => `
      <div class="flex items-center space-x-2 bg-slate-100 rounded-full px-3 py-1">
        <div class="w-6 h-6 bg-[#FF6D75] rounded-full flex items-center justify-center text-xs font-medium text-white">
          ${viewer.name.charAt(0).toUpperCase()}
        </div>
        <span class="text-xs text-slate-700">${viewer.name}</span>
      </div>
    `).join('')

    this.viewersTarget.innerHTML = `
      <div class="flex items-center space-x-2">
        <span class="text-xs text-slate-500">현재 보는 사람:</span>
        ${html}
      </div>
    `
  }
}