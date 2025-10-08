// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this._onKeydown = (e) => { if (e.key === "Escape") this.close() }
    document.addEventListener("keydown", this._onKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this._onKeydown)
  }

  close(e) {
    if (e) e.preventDefault()
    // モーダル要素を空にする
    this.element.innerHTML = ""
  }

  backdrop(e) {
    // 背景クリック時のみ閉じる
    if (e.target === e.currentTarget) this.close(e)
  }

  stop(e) {
    // モーダル内部のクリックはバブリングさせない
    e.stopPropagation()
  }
}
