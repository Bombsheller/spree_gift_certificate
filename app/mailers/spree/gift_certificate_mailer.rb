module Spree
  class GiftCertificateMailer < ActionMailer::Base

    def purchased_gift_certificate_email(gift_certificate)
      @gift_certificate = gift_certificate
      @gift_certificate_url = Spree::Store.site_url + "/gift_certificates/#{@gift_certificate.id}"
      mail(to: @gift_certificate.sender_email, subject: "Your #{Spree::Store.name} Gift Certificate")
    end
  end
end