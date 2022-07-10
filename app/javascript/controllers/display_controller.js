import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="display"
export default class extends Controller {
  static targets = [ "showable"]

  toggleTargets(event) {
    
    event.preventDefault()

    this.showableTargets.forEach(el => {
      el.classList.toggle("showing")
    });
  }

}
