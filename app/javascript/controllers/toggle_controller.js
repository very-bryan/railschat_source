import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]
  static values = { 
    url: String,
    field: String
  }
  
  connect() {
    // 초기 상태 설정
    this.checkboxTarget.addEventListener('change', this.toggle.bind(this))
  }
  
  disconnect() {
    this.checkboxTarget.removeEventListener('change', this.toggle.bind(this))
  }
  
  toggle(event) {
    const isChecked = event.target.checked
    
    // 서버에 상태 업데이트 요청
    fetch(this.urlValue, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        [this.fieldValue]: isChecked
      })
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok')
      }
      return response.json()
    })
    .catch(error => {
      console.error('Error:', error)
      // 에러 발생 시 체크박스 상태를 되돌림
      event.target.checked = !isChecked
    })
  }
}