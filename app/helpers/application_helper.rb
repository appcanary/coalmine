require 'digest/md5'
module ApplicationHelper
  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} alert-dismissible", role: 'alert') do
        concat(content_tag(:button, class: 'close', data: { dismiss: 'alert' }) do
          concat content_tag(:span, '&times;'.html_safe, 'aria-hidden' => true)
          concat content_tag(:span, 'Close', class: 'sr-only')
        end)
        concat message
      end)
    end
    nil
  end

  def gravatar_img(email)
    ident = Digest::MD5.hexdigest(email.to_s.downcase)
    "https://gravatar.com/avatar/#{ident}?d=identicon"
  end

  def eui_button(value, opt = {})
    btn_type = "eui-button-medium-default"
    content_tag("eui-button", :class => "ember-view #{btn_type}") do
      content_tag("button", :type => "button", :'aria-label' => value) +
        content_tag("div", :class => "eui-component") do

        content_tag("div", :class => "eui-component-wrapper") do
          content_tag("div", :class => "eui-label") do
            content_tag("div", :class => "eui-label-value") do
              value
            end
          end
        end

      end
    end
  end
end
