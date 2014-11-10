class ChangeSpreeGiftCardPaymentIdToPaymentCode < ActiveRecord::Migration
  def change
    rename_column :spree_gift_certificates, :payment_id, :payment_code
    change_column :spree_gift_certificates, :payment_code, :string
  end
end
