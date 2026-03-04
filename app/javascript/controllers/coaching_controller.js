import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startButton", "personaButtons"]

  start(event) {
    event.preventDefault();
    this.startButtonTarget.classList.add("d-none");
    this.personaButtonsTarget.classList.remove("d-none");
  }
}
