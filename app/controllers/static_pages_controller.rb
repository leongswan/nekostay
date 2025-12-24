class StaticPagesController < ApplicationController
  # ログインしていなくてもLPは見れるようにする設定
  # ※ もしエラーが出る場合は、この1行を削除してください
  skip_before_action :authenticate_user!, only: [:top], raise: false

  def top
    # ログインしていない人向けのLPを表示するだけなので、
    # 中身は空っぽで大丈夫です！
  end
end
