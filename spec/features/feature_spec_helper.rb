def create_product
  @product ||= create(:product, :name => "RoR Mug", :price => 20)
end

def add_product_to_cart
  create_product
  visit spree.root_path
  click_link "RoR Mug"
  click_button "add-to-cart-button"
end