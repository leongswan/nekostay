// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this._onKeydown = (e) => { if (e.key === "Escape") this.element.remove() } // remove()に修正
    document.addEventListener("keydown", this._onKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this._onKeydown)
  }

  stop(e) {
    // モーダル内部のクリックはバブリングさせない
    e.stopPropagation()
  }

  close(e) {
  if (e) e.preventDefault()
  
  // フレーム自体をDOMから削除する
  // これが最もクリーンで、イベントの衝突を避ける方法です。
  this.element.remove() 
}

  backdrop(e) {
  // e.target: クリックされた要素
  // e.currentTarget: data-actionが設定されている要素 (div.modal-overlay)
  
  // クリックされた要素がオーバーレイ（背景）と一致する場合のみ閉じる
  if (e.target === e.currentTarget) {
    this.close(e)
  }
 }
}
