class ChangeSendingUserIdToEmailAndAddPaymentToGiftCertificates < ActiveRecord::Migration
  def change
    remove_column :spree_gift_certificates, :sending_user_id
    add_column :spree_gift_certificates, :sender_email, :string
    add_reference :spree_gift_certificates, :payment
  end
end
