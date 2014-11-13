module Spree
  class GiftCertificateMailer < ActionMailer::Base

    def purchased_gift_certificate_email(gift_certificate)
      @gift_certificate = gift_certificate
      @gift_certificate_url = Spree::Config.site_url + "/gift_certificates/#{@gift_certificate.id}"
      mail(to: @gift_certificate.sender_email, subject: "Your #{Spree::Config.site_name} Gift Certificate")
    end
  end
end