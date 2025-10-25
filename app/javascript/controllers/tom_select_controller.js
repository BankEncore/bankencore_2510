import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  connect() {
    this.ts = new TomSelect(this.element, { plugins: ["remove_button"], maxOptions: 5000, create: false })
  }
  disconnect() { this.ts?.destroy() }
}
