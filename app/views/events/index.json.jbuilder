json.array! @events do |event|
  json.extract! event, :created_at, :kind, :message
  json.app do 
    json.extract! event.app, :name, :platforms, :last_synced_at
    json.active_issues do
      json.array! event.app.active_issues do |vuln|
        json.extract! vuln, :title, :disclosed_at, :description, :criticality, :osvdb, :cve, :artifact, :remediation, :kind
      end
    end
  end
end
