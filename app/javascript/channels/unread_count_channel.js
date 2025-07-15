import consumer from "channels/consumer"

// Make function global so it can be used by other modules
window.updateChannelUnreadCount = function(channelId, unreadCount) {
  console.log(`[UnreadCountChannel] Updating channel ${channelId} with unread count: ${unreadCount}`);
  
  // Find the channel link in the sidebar
  const channelLinks = document.querySelectorAll(`a[href*="/chat/channel/${channelId}"]`);
  
  channelLinks.forEach(link => {
    const badge = link.querySelector('span:last-child');
    
    if (badge) {
      // Get member count from data attribute or current text if it's not unread count
      let memberCount = badge.dataset.memberCount;
      if (!memberCount) {
        // If current text is not a number with + or is small, it's probably member count
        const currentText = badge.textContent.trim();
        if (!currentText.includes('+') && parseInt(currentText) < 10) {
          memberCount = currentText;
          badge.dataset.memberCount = memberCount;
        }
      }
      
      // Check if we're currently viewing this channel
      const currentPath = window.location.pathname;
      const isCurrentChannel = currentPath.includes(`/chat/channel/${channelId}`);
      
      console.log(`[UnreadCountChannel] Channel ${channelId}: isCurrentChannel=${isCurrentChannel}, unreadCount=${unreadCount}`);
      
      if (unreadCount > 0 && !isCurrentChannel) {
        // Show unread count only if not on current channel
        badge.className = 'bg-[#FF6D75] text-white px-1.5 py-0.5 rounded-full text-xs font-medium';
        badge.textContent = unreadCount;
      } else {
        // Show member count or 0 if no unread messages
        const isSelected = link.classList.contains('bg-slate-200');
        badge.className = isSelected ? 
          'bg-slate-300 text-slate-700 px-1.5 py-0.5 rounded-full text-xs' : 
          'bg-slate-200 text-slate-600 px-1.5 py-0.5 rounded-full text-xs';
        badge.textContent = memberCount || '0';
      }
    }
  });
}

document.addEventListener('turbo:load', () => {
  consumer.subscriptions.create("UnreadCountChannel", {
    connected() {
      console.log('[UnreadCountChannel] Connected');
    },

    disconnected() {
      console.log('[UnreadCountChannel] Disconnected');
    },

    received(data) {
      console.log('[UnreadCountChannel] Received:', data);
      
      if (data.action === 'update_unread_count') {
        window.updateChannelUnreadCount(data.channel_id, data.unread_count);
      }
    }
  });
});
