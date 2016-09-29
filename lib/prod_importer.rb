class ProdImporter
  def initialize(account)
    @account = account
  end

  def kind_to_strategy(kind)
    case kind
    when /rubygem/
      :ruby_parcel
      # Platforms::Ruby
    when /debian/
      :dpkg_parcel
    when /ubuntu/
      :dpkg_parcel
    when /centos/
      :rpm_parcel
    when /amzn/
      :rpm_parcel
    else
      raise "wtf kind: #{kind}"
    end
  end

  def create_server(server_hsh)
    server_params = server_hsh.slice("uuid", "ip", "hostname", "name", "uname", "release", "distro")

    server_params["created_at"] = server_hsh["created-at"]
    rel = AgentRelease.where(:version => server_hsh["agent-version"]).first_or_create!
    server_params["agent_server_id"] = rel.id

    server = @account.agent_servers.where(:uuid => server_params["uuid"]).first_or_create!(server_params)
  end

  def create_server_bundle(server, app_hsh)
    bm = BundleManager.new(@account, server)

    # generate the PlatformRelease object
    platform = server.distro
    release = server.release

    # kind in apps belonging to servers are unset
    if app_hsh["path"] =~ /gemfile/i
      platform = Platforms::Ruby
      release = nil
    end

    pr, error = PlatformRelease.validate(platform, release)

    if error
      puts "ERROR WITH #{@account.email} - #{server.id} - pr #{platform} / #{release}"
      return
    end

    opt = {:path => app_hsh["path"],
           :name => app_hsh["name"]}

    # TODO: this script should be idempotent but
    # If we've seen this server before, skip it for now
    bundle_id = Bundle.where(:account_id => @account.id, 
                             :agent_server_id => server.id,
                             :name => opt[:name],
                             :path => opt[:path]).pluck("id").first

    if bundle_id
      return
    end

    package_list = fetch_pl(app_hsh["artifact-versions"])

    bundle, err = bm.create_or_update(pr, opt, package_list)

    if err
      binding.pry
    end

    bundle
  end

  def create_bundle(mon_hsh)
    bm = BundleManager.new(@account)
    
    pr, error = PlatformRelease.validate(mon_hsh["kind"], mon_hsh["release"])

    if error
      binding.pry
    end

    bundle = @account.bundles.where(:name => mon_hsh["name"]).first

    package_list = fetch_pl(mon_hsh["artifact-versions"])

    if bundle.nil?
      opt = {
        name: mon_hsh["name"],
        from_api: true
      }
      bundle, error = bm.create(pr, opt, package_list)
      if error
        binding.pry
      end
    else
      # TODO: This should be idempotent. Prior to
      # deployment this should be uncommented
      return
      # b, error = bm.update_packages(bundle.id, package_list)
      # if error
        # binding.pry
      # end
    end
  end

  def fetch_pl(artifacts)
    if artifacts.empty?
      return []
    end

    strategy = kind_to_strategy(artifacts.first["kind"])

    artifacts.map do |artver|
      send(strategy, artver)
    end
  end

  def rpm_parcel(artver)
    # the number is the EVR
    nevra = "#{artver["name"]}-#{artver["number"]}"

    if artver["arch"]
      nevra = "#{nevra}.#{artver["arch"]}"
    end

    Parcel::RPM.new(nevra)
  end

  def ruby_parcel(artver)
    Parcel::Rubygem.new({
      name: artver["name"],
      version: artver["number"]
    })
  end

  def dpkg_parcel(artver)
    hsh = {
      "Package" => artver["name"],
      "Version" => artver["number"]
    }

    if src = artver["source-artifact-name"]
      hsh["Source"] = src
    end

    Parcel::Dpkg.new(hsh)
  end


end

