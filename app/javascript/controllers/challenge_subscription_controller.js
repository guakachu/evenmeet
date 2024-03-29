import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static values = { challengeId: Number }
  static targets = ["messages"]

  connect() {
    this.channel = createConsumer().subscriptions.create(
      { channel: "ChallengeChannel", id: this.challengeIdValue },
      { received: data => this.#insertMessageAndScrollDown(data) }
      )
    window.scrollTo(0, document.body.scrollHeight);
  }

  disconnect() {
    console.log("Unsubscribed from the chatroom")
    this.channel.unsubscribe()
  }

  resetForm(event) {
    event.target.reset()
  }

  #insertMessageAndScrollDown(data) {
    if (data.message) {
      this.messagesTarget.insertAdjacentHTML("beforeend", data.message)
      this.messagesTarget.scrollTo(0, this.messagesTarget.scrollHeight)
    }
  }
}
