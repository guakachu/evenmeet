import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-element"
export default class extends Controller {
  static targets = ["modal"]
  connect() {
  }

  toggle() {
    this.modalTarget.classList.toggle("active");
  }
}
