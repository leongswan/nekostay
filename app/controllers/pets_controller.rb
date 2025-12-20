class PetsController < ApplicationController

  # ↓↓↓ この1行を追加してください！ ↓↓↓
  before_action :authenticate_user!
  # --------------------------------
  def index
    # 自分のペット一覧を表示
    @pets = current_user.pets.order(created_at: :desc)
  end

  def new
    # 新しいペット登録用
    @pet = Pet.new
  end

  def create
    # 登録ボタンが押されたときの処理
    @pet = current_user.pets.build(pet_params)

    if @pet.save
      redirect_to pets_path, notice: "新しい家族を登録しました！🐈"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # ↓↓↓ ここから追加してください ↓↓↓

  def edit
    # 編集したいペットのデータを探してくる
    # current_user.pets から探すことで、他人のペットを編集できないようにします
    @pet = current_user.pets.find(params[:id])
  end

  def update
    @pet = current_user.pets.find(params[:id])
    
    if @pet.update(pet_params)
      redirect_to pets_path, notice: "ペット情報を更新しました！✨"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # ↑↑↑ ここまで追加 ↑↑↑

  private

  def pet_params
    # 今は「名前」だけ許可します（後で種類や年齢も追加できます）
    params.require(:pet).permit(:name, :image)
  end
end