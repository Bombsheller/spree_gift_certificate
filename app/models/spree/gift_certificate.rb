module Spree
  class GiftCertificate < ActiveRecord::Base
    @@code_generator = GiftCodeGenerator.new
    before_validation do
      self.code = generate_code if code.nil?
    end

    validates :amount, :code, :sender_email, presence: true
    validates :amount, numericality: { greater_than: 0 }
    validates :code, uniqueness: true

    state_machine :state, initial: :pending do

      event :purchase do
        transition from: :pending, to: :purchased
      end
      before_transition to: :purchased do |certificate, transition|
        certificate.send(:make_charge, transition.args.first)
        certificate.send(:set_expiry)
        fail 'Gift certificate cannot be purhcased.' unless certificate.errors.empty?
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
        if expiry > Date.today # Certificate has not yet expired
          self.recipient_user_id = user.id
          begin
            self.save!
            self.redeem!
            status[:notice] = "Successfully redeemed gift certificate for #{Spree::Money.new(amount)}! You now have #{user.store_credits_total} in store credit."
          rescue StateMachine::InvalidTransition
            status[:error] = "Could not redeem gift certificate because #{nice_failure_reason}."
          rescue Exception
            status[:error] = 'Something went wrong. Please try again.'
          end
        else
          status[:error] = 'Gift card has expired.'
        end
      else
        status[:error] = 'Need to be logged in to redeem a gift certificate.'
      end
      status
    end

    def stripe_publishable_key
      @stripe_publishable_key ||= stripe_payment_methods.first.preferred_publishable_key if stripe_payment_methods.length > 0
    end

    private

      def stripe_payment_methods
        PaymentMethod.where(environment: Rails.env, active: true).select { |m| m.type.match(/stripe/i) }
      end

      def stripe_secret_key
        stripe_payment_methods.first.preferred_secret_key if stripe_payment_methods.length > 0
      end

      def generate_code
        code = @@code_generator.generate
        while GiftCertificate.find_by_code(code)
          code = @@code_generator.generate
        end
        code
      end

      def award_store_credit
        Spree::StoreCredit.create!(
          user_id: recipient_user_id,
          amount: amount,
          remaining_amount: amount,
          reason: "Spree::GiftCertificate, code: #{code}")
      end

      def make_charge(stripe_token)
        return errors.add(:payment, 'No payment info supplied.') unless stripe_token
        begin
          stripe_gateway = ActiveMerchant::Billing::StripeGateway.new(login: stripe_secret_key)
          charge = stripe_gateway.purchase(amount.to_i * 100, stripe_token['id'])
          self.payment_code = charge.params['id']
          self.save
        rescue Exception
          # Charge messed up
          errors.add(:payment, 'Something went wrong with your card. Please try again.')
        end
      end

      def set_expiry
        self.expiry = 1.year.from_now
      end

      def nice_failure_reason
        if state == 'redeemed'
          'it has already been redeemed'
        elsif state == 'refunded'
          'the purchaser got a refend'
        elsif state == 'pending'
          'the certificate has not yet been paid for'
        end
      end
  end
end