module Spree
  class GiftCertificate < ActiveRecord::Base
    validates :amount, :code, :gift_to, presence: true
    validates :amount, numericality: true
    validates :code, uniqueness: true

    state_machine :state, initial: :pending do

      event :purchase do
        transition from: :pending, to: :purchased
      end
      before_transition to: :purchased do |certificate, transition|
        certificate.send(:ensure_email_and_payment, transition.args.first)
      end

      event :redeem do
        transition from: :purchased, to: :redeemed
      end
      after_transition to: :redeemed, do: :award_store_credit

      event :refund do
        transition from: :purchased, to: :refunded
      end
    end

    def recipient
      Spree::User.find(recipient_user_id)
    end

    def redeem_for!(user)
      self.recipient_user_id = user.id
      self.save!
      self.redeem!
    end

    private
      def award_store_credit
        Spree::StoreCredit.create!(
          user_id: recipient_user_id,
          amount: amount,
          remaining_amount: amount,
          reason: "Spree::GiftCertificate")
      end

      def ensure_email_and_payment(transition_args)
        raise 'Need an email address to purchase a gift certificate.' if !transition_args.has_key?(:sender_email)
        raise 'Need payment info.' if !transition_args.has_key?(:payment_id)
        self.sender_email = transition_args[:sender_email]
        self.payment_id = transition_args[:payment_id]
        self.save!
      end
  end
end