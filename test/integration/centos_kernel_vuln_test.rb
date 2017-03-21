require 'test_helper'

class CentosKernelVulnTest < ActionDispatch::IntegrationTest
  let(:account) {  FactoryGirl.create(:account) }
  it "should not mark kernels as vulnerable to the alt kernel" do

    # stub out update_local_store! since it expects a git repository
    CesaImporter.any_instance.stubs(:update_local_store!).returns(nil)
    # We have a single vulnerability in the Xen centos kernel
    @importer = CesaImporter.new("test/data/importers/cesa_alt_kernel")
    @importer.import!
    VulnerabilityImporter.new(CesaImporter::PLATFORM, CesaImporter::SOURCE).import


    # We just have one vulnerability
    assert_equal 1, Vulnerability.count

    centos6 = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "test/data/parsers", "centos-6-rpmqa.txt")))
    post api_check_path, {platform: Platforms::CentOS, release: "6", file: centos6},  {authorization: %{Token token="#{account.token}"}}

    assert_response :success

    # We should have 0 vulnerabilities in the test data since it's using the mainline (non xen) kernel
    json =  JSON.parse(response.body)
    assert json.key?("data")
    assert_empty json["data"]
    assert_equal false, json["meta"]["vulnerable"]
  end
end
