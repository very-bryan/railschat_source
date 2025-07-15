import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static values = { channelId: Number }
  
  connect() {
    console.log("Channel reactions controller connected with channel ID:", this.channelIdValue);
    console.log("Element:", this.element);
    console.log("Has channel ID value:", this.hasChannelIdValue);
    
    // Try different ways to get channel ID
    const channelId = this.channelIdValue || this.element.dataset.channelId || this.element.dataset.channelReactionsChannelIdValue;
    console.log("Final channel ID:", channelId);
    
    if (channelId) {
      this.subscription = consumer.subscriptions.create(
        { channel: "ChannelReactionsChannel", channel_id: channelId },
        {
          connected: () => {
            console.log("✅ Connected to reactions channel for channel", channelId);
          },

          disconnected: () => {
            console.log("Disconnected from reactions channel");
          },

          received: (data) => {
            console.log("Received reaction update:", data);
            this.updateMessage(data);
          }
        }
      );
    }
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe();
    }
  }

  updateMessage(data) {
    console.log("Updating message:", data.message_id, "with reactions:", data.reactions);
    const messageElement = document.getElementById(`message-${data.message_id}`);
    if (messageElement) {
      console.log("Found message element");
      // Check if this is a removal action
      if (data.action === 'remove') {
        messageElement.remove();
        return;
      }
      
      // Update reactions
      if (data.reactions !== undefined) {
        let reactionsContainer = messageElement.querySelector('.flex.flex-wrap.gap-2.mt-2');
        
        if (!reactionsContainer && Object.keys(data.reactions).length > 0) {
          reactionsContainer = document.createElement('div');
          reactionsContainer.className = 'flex flex-wrap gap-2 mt-2';
          const messageContent = messageElement.querySelector('.flex-1.min-w-0');
          if (messageContent) {
            messageContent.appendChild(reactionsContainer);
          }
        }
        
        if (reactionsContainer) {
          // Clear existing reactions
          reactionsContainer.innerHTML = '';
          
          // Add updated reactions
          Object.entries(data.reactions).forEach(([emoji, reactionData]) => {
            const reactionDiv = document.createElement('div');
            reactionDiv.className = 'relative group/reaction';
            
            const button = document.createElement('button');
            button.className = 'inline-flex items-center gap-1 hover:scale-110 transition-transform';
            button.setAttribute('onclick', `toggleReaction('${data.message_id}', '${emoji}')`);
            // Use textContent and appendChild instead of innerHTML to avoid TrustedHTML error
            const emojiSpan = document.createElement('span');
            emojiSpan.className = 'text-xl';
            emojiSpan.textContent = emoji;
            
            const countSpan = document.createElement('span');
            countSpan.className = 'text-xs font-medium text-slate-500';
            countSpan.textContent = reactionData.count;
            
            button.appendChild(emojiSpan);
            button.appendChild(countSpan);
            
            reactionDiv.appendChild(button);
            reactionsContainer.appendChild(reactionDiv);
          });
          
          // Remove reactions container if empty
          if (Object.keys(data.reactions).length === 0) {
            reactionsContainer.remove();
          }
        }
      }
    }
  }
}