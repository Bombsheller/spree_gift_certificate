class CreateSpreeGiftCertificates < ActiveRecord::Migration
  def change
    create_table :spree_gift_certificates do |t|
      t.string :state
      t.decimal :amount
      t.references :user
      t.string :code
      t.string :gift_from
      t.string :gift_to
      t.string :message
    end
  end
end
