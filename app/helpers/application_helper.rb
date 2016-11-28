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

  def show_package_path(package)
    if package.release.nil?
      package_platform_path(package.platform, package.name, package.version)
    else
      package_platform_release_path(package.platform, package.release, package.name, package.version)
    end
  end

  def gravatar_img(email)
    ident = Digest::MD5.hexdigest(email.to_s.downcase)
    "https://gravatar.com/avatar/#{ident}?d=identicon"
  end

  def eui_button(value, opt = {}, html = {})
    btn_type = opt[:type] || "eui-button-medium-default"
    disabled = opt[:disabled] ? "eui-disabled" : nil
    klass = opt[:class] ? opt[:class] : nil
    tag_attr = {:class => "ember-view #{btn_type} #{disabled} #{klass}"}

    content_tag("eui-button", tag_attr.merge(html)) do
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
    versions.map { |pv| "<code>#{h pv}</code>" }.join(" or ").html_safe
  end

  def sort_versions(versions)
    versions.sort { |a, b| a.gsub(/\D/, '') <=> b.gsub(/\D/, '')}
  end

  def display_upgrade_to(package, vd)
    patches = package.upgrade_to_given(vd)

    if patches.present?
      patches.map { |pv|  "<code>#{h pv}</code>" }.join("<br/>").html_safe
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

  def email_display_upgrade_to(package)
    patches = sort_versions(package.upgrade_to)
    main_ver = patches[0]
    remaining_patches = patches[1..-1]

    str = nil

    if main_ver
      str = "<p>Upgrade to: <code>#{h main_ver}</code></p>"
      if remaining_patches.present?
        str += "<p>Other safe versions: #{remaining_patches.map { |pv| "<code>#{h pv}</code>" }.join(", ")}"
      end
    else
      str = "<p>Upgrade to: No patches exist right now.</p>"
    end

    str.html_safe
    
  end

  def time_ago_in_words_or_never(time)
    if time
      "#{time_ago_in_words time} ago"
    else
      "never ago"
    end
  end

  def link_to_server_or_monitor(log)
    if log.has_server?
      link_to log.server.display_name, server_app_url(log.bundle, server_id: log.server.id)
    else 
      link_to log.bundle.display_name, monitor_url(log.bundle)
    end
  end

  def link_to_bundle(bundle)
    if bundle.agent_server_id
      link_to "#{bundle.agent_server.display_name} - #{bundle.display_name}", server_app_url(bundle, server_id: bundle.agent_server_id)
    else
      link_to bundle.display_name, monitor_url(bundle)
    end
  end

  def render_vuln_description(vuln)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(escape_html: true), autolink: true, tables: true, no_intra_emphasis: true, fenced_code_blocks: true)
    markdown.render(vuln.description).html_safe
  end

  def platform_icon(platform)
    if label = Platforms.supported?(platform)
      content_tag("span", :class => "platform-logo") do 
        image_tag("icon-#{platform}.png", :style => "width: 13px") + 
          " #{label}"
      end
    else
      "Unsupported platform"
    end
  end
end
