// Chat functionality
export function initializeChat() {
  // Message actions
  window.showEmojiPicker = function(event, messageId) {
    event.stopPropagation();
    closeAllPopups();
    
    const picker = document.getElementById(`emoji-picker-${messageId}`);
    if (!picker) return;
    
    const rect = event.target.getBoundingClientRect();
    picker.style.position = 'fixed';
    picker.style.top = (rect.bottom + 5) + 'px';
    picker.style.left = Math.min(rect.left, window.innerWidth - 300) + 'px';
    picker.classList.remove('hidden');
  }

  window.showMoreMenu = function(event, messageId) {
    event.stopPropagation();
    closeAllPopups();
    
    const menu = document.getElementById(`more-menu-${messageId}`);
    if (!menu) return;
    
    const rect = event.target.getBoundingClientRect();
    menu.style.position = 'fixed';
    menu.style.top = (rect.bottom + 5) + 'px';
    menu.style.right = (window.innerWidth - rect.right) + 'px';
    menu.classList.remove('hidden');
  }

  window.closeAllPopups = function() {
    document.querySelectorAll('[id^="emoji-picker-"], [id^="more-menu-"]').forEach(el => {
      el.classList.add('hidden');
    });
  }

  window.addReaction = async function(messageId, emoji) {
    closeAllPopups();
    
    try {
      const response = await fetch(`/messages/${messageId}/reactions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ emoji: emoji })
      });
      
      if (!response.ok) throw new Error('Failed to add reaction');
    } catch (error) {
      console.error('Error:', error);
      showToast('이모지 추가 중 오류가 발생했습니다');
    }
  }

  window.toggleReaction = async function(messageId, emoji) {
    try {
      const response = await fetch(`/messages/${messageId}/toggle_reaction`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ emoji: emoji })
      });
      
      if (!response.ok) throw new Error('Failed to toggle reaction');
    } catch (error) {
      console.error('Error:', error);
    }
  }

  window.replyToMessage = function(messageId, userName) {
    const input = document.querySelector('#message_body');
    if (input) {
      input.value = `@${userName} `;
      input.focus();
      input.dataset.parentMessageId = messageId;
    }
  }

  window.toggleSave = async function(messageId) {
    try {
      const response = await fetch(`/messages/${messageId}/save`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      });
      
      if (!response.ok) throw new Error('Failed to save message');
      showToast('메시지가 저장되었습니다');
    } catch (error) {
      console.error('Error:', error);
      showToast('저장 중 오류가 발생했습니다');
    }
  }

  window.togglePin = async function(messageId) {
    closeAllPopups();
    
    try {
      const response = await fetch(`/messages/${messageId}/pin`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      });
      
      if (!response.ok) throw new Error('Failed to pin message');
    } catch (error) {
      console.error('Error:', error);
      showToast('고정 중 오류가 발생했습니다');
    }
  }

  window.forwardMessage = function(messageId) {
    closeAllPopups();
    showToast('전달 기능은 준비 중입니다');
  }

  window.deleteMessage = async function(messageId) {
    closeAllPopups();
    
    if (!confirm('메시지를 삭제하시겠습니까?')) return;
    
    try {
      const response = await fetch(`/messages/${messageId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      });
      
      if (!response.ok) throw new Error('Failed to delete message');
    } catch (error) {
      console.error('Error:', error);
      showToast('삭제 중 오류가 발생했습니다');
    }
  }

  window.showToast = function(message) {
    const toast = document.createElement('div');
    toast.className = 'fixed bottom-4 right-4 bg-slate-900 text-white px-4 py-2 rounded-lg shadow-lg z-50 animate-fade-in';
    toast.textContent = message;
    document.body.appendChild(toast);
    
    setTimeout(() => toast.remove(), 3000);
  }

  window.toggleChannelForm = function() {
    const form = document.getElementById('channelForm');
    if (form) {
      form.classList.toggle('hidden');
    }
  }

  // Event listeners
  document.addEventListener('click', () => {
    closeAllPopups();
  });

  // Auto-scroll messages
  const scrollToBottom = () => {
    const messagesContainer = document.getElementById('messages-container');
    if (messagesContainer) {
      messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
  };

  // Scroll on page load
  scrollToBottom();

  // Scroll on new messages
  document.addEventListener('turbo:stream-render', () => {
    setTimeout(scrollToBottom, 100);
  });
}