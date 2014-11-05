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
        certificate.send(:set_expiry)
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

    def redeem_for(user)
      status = {}
      if user
        if self.expiry > Date.today # Certificate has not yet expired
          self.recipient_user_id = user.id
          begin
            self.save!
            self.redeem!
            status[:notice] = "Successfully redeemed gift certificate for #{Spree::Money.new(amount).to_s}! You now have #{user.store_credits_total} in store credit."
          rescue StateMachine::InvalidTransition => e
            status[:error] = "Could not redeem gift certificate because #{nice_failure_reason(e)}."
          rescue Exception => e
            status[:error] = "Something went wrong. Please try again."
          end
        else
          status[:error] = "Gift card has expired."
        end
      else
        status[:error] = "Need to be logged in to redeem a gift certificate."
      end
      status
    end

    private
      def award_store_credit
        Spree::StoreCredit.create!(
          user_id: recipient_user_id,
          amount: amount,
          remaining_amount: amount,
          reason: "Spree::GiftCertificate, code: #{self.code}")
      end

      def ensure_email_and_payment(transition_args)
        raise 'Need an email address to purchase a gift certificate.' if !transition_args.has_key?(:sender_email)
        raise 'Need payment info.' if !transition_args.has_key?(:payment_id)
        raise 'Something went wrong. Please try again.' if !self.expiry
        self.sender_email = transition_args[:sender_email]
        self.payment_id = transition_args[:payment_id]
        self.save!
      end

      def set_expiry
        self.expiry = Date.today
      end

      def nice_failure_reason(exception)
        if self.state == 'redeemed'
          'it has already been redeemed'
        elsif self.state == 'refunded'
          'the purchaser got a refend'
        elsif self.state == 'pending'
          'the certificate has not yet been paid for'
        end
      end
  end
end