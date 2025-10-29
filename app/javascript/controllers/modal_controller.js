// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    // --- 修正 ---
    //
    // 'is-visible' クラスに依存するのをやめ、
    // JSで直接スタイルを 'display: block' に書き換えて強制表示します。
    // (モーダルのCSSが 'display: block' で表示されることを想定)
    this.element.style.display = "block"
    //
    // --- 修正ここまで ---
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
