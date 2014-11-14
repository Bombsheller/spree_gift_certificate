Deface::Override.new(
  name: 'add_gift_certificates_to_product_sub_menu',
  virtual_path: 'spree/admin/shared/_product_sub_menu',
  insert_after: 'erb[loud]:contains("tab :taxons")',
  text: '<%= tab :gift_certificates %>'
  )