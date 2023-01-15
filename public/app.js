import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
window.Stimulus = Application.start()

Stimulus.register("category", class extends Controller {
  static targets = ["label", "input"]

  edit() {
    this.labelTarget.classList.add('d-none')
    this.inputTarget.classList.remove('d-none')
  }
})

Stimulus.register("amount", class extends Controller {
  static targets = ["label", "input"]

  edit() {
    this.labelTarget.classList.add('d-none')
    this.inputTarget.classList.remove('d-none')
  }
})

Stimulus.register("form", class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
})
