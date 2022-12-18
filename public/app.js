import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
window.Stimulus = Application.start()

Stimulus.register("chart", class extends Controller {
  connect() {
    console.log("Hello world")
  }
})
