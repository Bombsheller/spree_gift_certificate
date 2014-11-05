class AddExpirationToGiftCertificates < ActiveRecord::Migration
  def change
    add_column :spree_gift_certificates, :expiry, :date
  end
end
