import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  close(){ document.getElementById("modal").innerHTML = "" }
  backdrop(e){ if(e.target === e.currentTarget) this.close() }
  stop(e){ e.stopPropagation() }
}
