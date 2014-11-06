Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  get 'gift_certificates', to: 'gift_certificates#new'
end
