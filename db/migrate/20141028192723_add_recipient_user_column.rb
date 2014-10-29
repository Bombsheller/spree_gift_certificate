class AddRecipientUserColumn < ActiveRecord::Migration
  def change
    add_reference :spree_gift_certificates, :recipient_user
    rename_column :spree_gift_certificates, :user_id, :sending_user_id
  end
end
