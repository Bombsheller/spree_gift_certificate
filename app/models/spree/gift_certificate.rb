module Spree
  class GiftCertificate < ActiveRecord::Base
    validates :amount, :code, :gift_to, presence: true
    validates :amount, numericality: true
    validates :code, uniqueness: true

    state_machine :state, initial: :purchased do
      event :redeem do
        transition from: :purchased, to: :redeemed
      end
      after_transition to: :redeemed, do: :award_store_credit

      event :refund do
        transition from: :purchased, to: :refunded
      end
    end

    def recipient_user
      Spree::User.find(recipient_user_id)
    end

    private
      def award_store_credit
        Spree::StoreCredit.create!(
          user_id: recipient_user_id,
          amount: amount,
          remaining_amount: amount,
          reason: "Spree::GiftCertificate")
      end
  end
end