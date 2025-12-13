Rails.configuration.stripe = {
  # 公開可能キー (Publishable Key)
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'], 
  
  # シークレットキー (Secret Key)
  secret_key:      ENV['STRIPE_SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]