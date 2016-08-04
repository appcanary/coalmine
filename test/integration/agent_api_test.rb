require 'test_helper'

class AgentApiTest < ActionDispatch::IntegrationTest
  it "should register a new server" do
    assert_equal 0, AgentServer.count
    post api_agent_servers_path, {hostname: "maryanne.local", uname: "somefake machine data here", ip: "192.168.2.12", name: "somename", distro: "testD", release: "testR"}.to_json, {"Content-Type": 'application/json'}

    assert_response :success
    assert_equal 1, AgentServer.count
    server = AgentServer.first

    resp_body = JSON.parse(body)
    assert_equal server.uuid, resp_body["uuid"]
  end

  it "should register heartbeats to existing apps" do
    server = FactoryGirl.create(:agent_server, :centos).reload

    assert server.agent_release.nil?
    assert_equal 0, AgentHeartbeat.count

    post api_agent_server_heartbeat_path(server.uuid),
      {"agent-version" => "unreleased",  :distro => "testD", :release => "testR", :files => [{"being-watched" => true, :crc => 1213720459, :kind => "gemfile", :updated_at => DateTime.parse("2016-07-26 12:00")}]}.to_json,
      {"Content-Type": 'application/json'}

    server.reload
    assert_equal 1, server.heartbeats.count
    assert_equal "unreleased", server.agent_release.version
  end

  it "should accept files, including when they change" do
    server = FactoryGirl.create(:agent_server, :centos).reload

    assert_equal 0, server.bundles.count

    gemfile_lock = hydrate("3219rails.gemfile.lock")
    crc = Zlib::crc32(gemfile_lock)
    b64_file = Base64.encode64(gemfile_lock)

    path = "/Users/phillmv/code/c/newapi/Gemfile.lock"

    put api_agent_server_update_path(server.uuid), 
      {contents: b64_file, crc: crc, kind: "gemfile", name: "", path: path}.to_json, 
      {"Content-Type": 'application/json'}

    assert_response :success
    assert_equal 1, server.bundles.count
    b = server.bundles.first

    assert_equal 103, b.packages.count
    assert_equal path, b.path
    assert_equal "3.2.19", b.packages.where(:name => "rails").first.version

    # let's submit some changes!

    gemfile_lock = hydrate("420rails.gemfile.lock")
    crc = Zlib::crc32(gemfile_lock)
    b64_file = Base64.encode64(gemfile_lock)

    put api_agent_server_update_path(server.uuid), 
      {contents: b64_file, crc: crc, kind: "gemfile", name: "", path: path}.to_json, 
      {"Content-Type": 'application/json'}

    assert_equal 1, server.bundles.count
    assert_equal 146, b.packages.count 
    assert_equal "4.2.0", b.packages.where(:name => "rails").first.version


    # okay. what happens when I resubmit this but I change the path?
    put api_agent_server_update_path(server.uuid), 
      {contents: b64_file, crc: crc, kind: "gemfile", name: "", path: path + "LOL"}.to_json, 
      {"Content-Type": 'application/json'}

    assert_equal 2, server.bundles.count
  end

  # TODO: make this more exhaustive?
  it "should log requests when things look fishy" do
    server = FactoryGirl.create(:agent_server, :centos).reload

    assert_equal 0, AgentReceivedFile.count

    gemfile_lock = hydrate("3219rails.gemfile.lock")
    crc = Zlib::crc32(gemfile_lock)
    b64_file = Base64.encode64(gemfile_lock)
    path = "/Users/phillmv/code/c/newapi/Gemfile.lock"

    put api_agent_server_update_path(server.uuid), 
      {contents: b64_file, crc: crc, kind: "FAKEKIND", name: "", path: path}.to_json, 
      {"Content-Type": 'application/json'}

    assert_response :bad_request
    assert_equal 1, server.received_files.count

    put api_agent_server_update_path(server.uuid), 
      {contents: "obviouslygarbage", crc: crc, kind: "gemfile", name: "", path: path}.to_json, 
      {"Content-Type": 'application/json'}

    assert_equal 2, server.received_files.count
  end
end
