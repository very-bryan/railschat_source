import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]
  
  connect() {
    console.log('[Dropdown] Controller connected')
    this.open = false
    document.addEventListener("click", this.clickOutside.bind(this))
  }
  
  disconnect() {
    document.removeEventListener("click", this.clickOutside.bind(this))
  }
  
  toggle(event) {
    event.stopPropagation()
    console.log('[Dropdown] Toggle clicked, current state:', this.open)
    this.open = !this.open
    this.updateMenu()
  }
  
  close() {
    this.open = false
    this.updateMenu()
  }
  
  updateMenu() {
    if (this.open) {
      this.menuTarget.classList.remove("hidden")
      this.menuTarget.classList.add("opacity-100", "scale-100")
      this.menuTarget.classList.remove("opacity-0", "scale-95")
      this.buttonTarget.setAttribute("aria-expanded", "true")
    } else {
      this.menuTarget.classList.add("opacity-0", "scale-95")
      this.menuTarget.classList.remove("opacity-100", "scale-100")
      setTimeout(() => {
        if (!this.open) {
          this.menuTarget.classList.add("hidden")
        }
      }, 200)
      this.buttonTarget.setAttribute("aria-expanded", "false")
    }
  }
  
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}