class VulnsDashboardDataTablesSerializer < ActiveModel::Serializer
  attributes :draw, :recordsTotal, :recordsFiltered, :data

  def draw
    @instance_options[:draw]
  end

  def recordsTotal
    @instance_options[:total_count]
  end

  def recordsFiltered
    @instance_options[:filtered_count]
  end

  def data
    @object.map do |vuln| 

      { vuln: "#{scope.platform_icon(vuln.platform,false)} #{scope.link_to vuln.title, scope.vuln_path(vuln)}",
        criticality: vuln.criticality,
        tags: format_tags(vuln.tags),
        occurred_at: scope.time_ago_in_words(vuln.occurred_at),
        ignore: <<-EOS
        <eui-button class="ember-view eui-button-small-warning  " data-toggle="modal" data-target="#modal-1234-resolution" aria-haspopup="true"
        aria-expanded="false"><button aria-label="Wontfix"></button>
        <div class="eui-component">
          <div class="eui-component-wrapper">
            <div class="eui-label"><a class="eui-label-value">Wontfix</a></div>
          </div>
        </div>
      </eui-button>

      <eui-button class="ember-view eui-button-small-danger  " data-toggle="modal" data-target="#modal-1234-ignore" aria-haspopup="true"
        aria-expanded="false"><button aria-label="Ignore"></button>
        <div class="eui-component">
          <div class="eui-component-wrapper">
            <div class="eui-label"><a class="eui-label-value">Ignore</a></div>
          </div>
        </div>
      </eui-button>
      EOS
       }
    end
  end

  private
  def format_tags(tags)
    tagged, untagged =  tags.partition(&:present?) 
    r = tagged.flatten.group_by { |t| t }.map { |t, a| [t, a.size]}.sort_by(&:first).map { |t, s| scope.link_to("#{t} (#{s})", "", class: "btn btn-sm btn-default")}.join(" ")
    if untagged.present?
      r += " " + scope.link_to("untagged (#{untagged.size})", "",  class: "btn btn-sm btn-default")
    end
    r
  end
end