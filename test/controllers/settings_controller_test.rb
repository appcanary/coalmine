require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }

  it "user should be able to change their password" do
    login_user(user)
    new_pw = "12345678"

    assert_not_nil @controller.send(:login, user.email, TestValues::PASSWORD)

    post :update, :user => { :password => new_pw,
                             :password_confirmation => new_pw}

    assert_nil  @controller.send(:login, user.email, TestValues::PASSWORD)
    assert_not_nil  @controller.send(:login, user.email, new_pw)
  end

  it "should let users change their email" do
    login_user(user)

    new_email = "new@example.com"

    client = mock
    client.expects(:update_user).with(anything).returns('{"id":17592186873228,"name":"","email":"new@example.com","web-token":"142knb7121o0n0cvu7ho0uet0ah25leo9iokea3eki7o3ngarlu9","agent-token":"1itfk3sfeudtj1tj0vmkkcbemalgjv4bi3rrkl84he86h78rrnmk"}')
    Canary.stubs(:new).with(anything).returns(client)

    post :update, :user => { :email => new_email }

    user.reload
    assert_equal user.email, new_email
  end

   it "users changing their email should fail gracefully" do
    login_user(user)

    new_email = "new@example.com"

    client = mock
    client.expects(:update_user).with(anything).raises(Faraday::Error, "lol nope")
    client.expects(:me).with(anything).returns({"agent-token": "test"})
    Canary.stubs(:new).with(anything).returns(client)

    post :update, :user => { :email => new_email }

    assert user.errors["email"].present?

    user.reload
    assert_not_equal user.email, new_email
  end

end
