import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="debounce"
export default class extends Controller {
  static targets = [ "form" ]
  
  // debounces search requests as users enter text
  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
        this.formTarget.requestSubmit()
      }, 250)
  }
}
