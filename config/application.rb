require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Nekostay
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))


    # --- ★★★ 修正・追加箇所 ★★★ ---
    
    # 1. アプリの言葉を日本語にする
    config.i18n.default_locale = :ja
    
    # 2. 時計を日本時間 (JST) に合わせる
    # これがないと、日記やチャットの時間が9時間ずれてしまいます
    config.time_zone = 'Tokyo'
    
    # 3. データベースに保存する時間はUTC（世界標準時）のままにする（Railsの推奨設定）
    config.active_record.default_timezone = :utc

    # --- ここまで ---


    config.autoload_paths << Rails.root.join("lib")
    
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end