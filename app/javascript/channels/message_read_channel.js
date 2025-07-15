import consumer from "channels/consumer"

let messageReadSubscription = null;

document.addEventListener('turbo:load', () => {
  const channelElement = document.getElementById('messagesContainer') || document.getElementById('messages-container');
  
  if (channelElement) {
    const channelId = channelElement.dataset.channelId;
    
    if (channelId) {
      // Unsubscribe from previous channel if exists
      if (messageReadSubscription) {
        messageReadSubscription.unsubscribe();
      }
      
      messageReadSubscription = consumer.subscriptions.create(
        { 
          channel: "MessageReadChannel",
          channel_id: channelId
        },
        {
          connected() {
            console.log('[MessageReadChannel] Connected to channel:', channelId);
            // Force update the unread count when entering the channel
            setTimeout(() => {
              console.log('[MessageReadChannel] Forcing unread count update for current channel');
              const unreadCountBadge = document.querySelector(`a[href*="/chat/channel/${channelId}"] span:last-child`);
              if (unreadCountBadge && unreadCountBadge.classList.contains('bg-[#FF6D75]')) {
                console.log('[MessageReadChannel] Found unread badge, clearing it');
                if (window.updateChannelUnreadCount) {
                  window.updateChannelUnreadCount(channelId, 0);
                }
              }
            }, 1000);
          },

          disconnected() {
            console.log('[MessageReadChannel] Disconnected');
          },

          received(data) {
            console.log('[MessageReadChannel] Received:', data);
            
            if (data.action === 'message_read') {
              updateReadStatus(data.message_id, data.readers_count);
            }
          },
          
          markAsRead(messageId) {
            this.perform('mark_as_read', { message_id: messageId });
          }
        }
      );
      
      // Mark messages as read when they appear in viewport
      observeMessagesForReading();
    }
  }
});

function updateReadStatus(messageId, readersCount) {
  const messageEl = document.getElementById(`message-${messageId}`);
  if (!messageEl) return;
  
  // Update read status UI (we'll add this next)
  const readIndicator = messageEl.querySelector('.read-indicator');
  if (readIndicator) {
    readIndicator.textContent = `✓✓ ${readersCount}`;
  }
}

function observeMessagesForReading() {
  const options = {
    root: document.getElementById('messagesContainer') || document.getElementById('messages-container'),
    rootMargin: '0px',
    threshold: 0.5
  };
  
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const messageId = entry.target.id.replace('message-', '');
        if (messageReadSubscription) {
          messageReadSubscription.markAsRead(messageId);
        }
      }
    });
  }, options);
  
  // Observe all messages
  document.querySelectorAll('[id^="message-"]').forEach(messageEl => {
    observer.observe(messageEl);
  });
}

// Re-observe new messages when they are added
document.addEventListener('turbo:stream-render', () => {
  setTimeout(() => {
    observeMessagesForReading();
  }, 100);
});
