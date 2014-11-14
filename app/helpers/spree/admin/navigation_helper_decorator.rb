Spree::Admin::NavigationHelper.module_eval do
  def link_to_resend_gift_certificate(resource, options={})
    options[:data] = {:action => 'resend'}
    url = resend_object_url(resource)
    link_to_with_icon('envelope', 'Resend', url, options)
  end

  def link_to_refund_gift_certificate(resource, options={})
    url = refund_object_url(resource)
    options[:data] = {:action => 'refund'}
    options[:data] = { :confirm => 'Are you sure you want to refund this gift ceritificate? This cannot be undone.' }
    link_to_with_icon('undo', 'Refund', url, options)
  end
end