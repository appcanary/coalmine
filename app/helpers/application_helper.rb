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
    disabled = opt[:disabled] ? "eui-disabled" : nil
    klass = opt[:class] ? opt[:class] : nil
    content_tag("eui-button", :class => "ember-view #{btn_type} #{disabled} #{klass}") do
      if disabled
      btn = content_tag("button", :disabled => true, :'aria-label' => value) {} 
      else
        btn = content_tag("button", :'aria-label' => value) {} 
      end
      btn +
        content_tag("div", :class => "eui-component") do

        content_tag("div", :class => "eui-component-wrapper") do
          content_tag("div", :class => "eui-label") do
            content_tag("a", :href => opt[:href], :class => "eui-label-value") do
              value
            end
          end
        end
      end
    end
  end

  def avatar(obj, size = :normal)
    case size
    when :normal
      klass = "icon"
    when :tiny
      klass = "icon tiny"
    end
    image_tag("data:image.png;base64,#{obj.avatar}", :class => klass)
  end


  def label_with_error(form, model, field)
    if model.errors[field].blank?
      form.label field
    else
      form.label field, "#{field.to_s.titleize} #{fmt_errors(model.errors[field])}".html_safe
    end
  end

  def fmt_errors(errors)
    content_tag("span", :class => "field-error") do 
      errors.join(" ")
    end
  end

  def versions_in_english(versions)
    versions.map { |pv| "<code>#{pv}</code>" }.join(" or ").html_safe
  end

  def sort_versions(versions)
    versions.sort { |a, b| a.gsub(/\D/, '') <=> b.gsub(/\D/, '')}
  end

  def upgrade_to(vuln)
    if vuln.patched_versions.present?
      versions = vuln.patched_versions.sort { |a, b| a.gsub(/\D/, '') <=> b.gsub(/\D/, '')}.map { |pv|  "<code>#{h pv}</code>" }.join("<br/>").html_safe
    else
      "No patches exist right now"
    end
  end

  def li_active(kontroller, aktion = nil) 
    same_action = true
    klass = ""
    if aktion
      same_action = aktion == action_name
    end

    if kontroller == controller_name && same_action
      klass = "active"
    end

    content_tag("li", :class => klass) do
      yield
    end
  end
end
