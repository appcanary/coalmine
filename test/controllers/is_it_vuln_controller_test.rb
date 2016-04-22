require 'test_helper'

class IsItVulnControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get sample" do
    get :sample_results
    assert_response :success
  end

  test "should work when you submit" do
    VCR.use_cassette("isitvuln_submit") do
      @request.accept = 'application/json'
      post :submit, {:file => Rack::Test::UploadedFile.new(File.join(Rails.root, "Gemfile.lock"), nil, false)}
    end

    r = JSON.load(response.body)
    assert_response :success
    assert r["id"]

      @request.accept = 'text/html'
    get :results, :ident => r["id"]
    assert_response :success

  end
end
