import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  const messagesContainer = document.getElementById('messages')
  const chatroomElement = document.getElementById('chatroom-id')

  if (chatroomElement && messagesContainer) {
    const chatroomId = chatroomElement.dataset.chatroomId

    consumer.subscriptions.create(
      { channel: "ChatroomChannel", chatroom_id: chatroomId },
      {
        received(data) {
          messagesContainer.insertAdjacentHTML('beforeend', data.content)
        }
      }
    )
  }
})