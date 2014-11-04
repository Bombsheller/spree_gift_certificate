Spree::StoreController.class_eval do
  prepend_before_action :redeem_gift_certificate, only: :update

  def redeem_gift_certificate
    if params[:order] && params[:order][:coupon_code] && certificate = gift_certificate_for(params[:order][:coupon_code])
      message = certificate.redeem_for(spree_current_user)
      flash[message.keys.first] = message.values.first
      params[:order].except!(:coupon_code)
    end
  end

  private
    def gift_certificate_for(entered_code)
      Spree::GiftCertificate.find_by_code(entered_code)
    end
end