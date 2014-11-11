Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  get 'gift_certificates', to: 'gift_certificates#new'
  post 'gift_certificates', to: 'gift_certificates#create'
  post 'buy_gift_certificate', to: 'gift_certificates#update'
  get 'gift_certificates/:id', to: 'gift_certificates#show'
end
