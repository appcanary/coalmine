require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }

  it "user should be able to change their password" do
    login_user(user)
    new_pw = "12345678"

    assert_not_nil @controller.send(:login, user.email, TestValues::PASSWORD)

    put :update, :user => { :password => new_pw,
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

    put :update, :user => { :email => new_email }

    user.reload
    assert_equal user.email, new_email
  end

  describe "Intercom" do
    before do
      client = mock
      client.stubs(:me).with(anything).returns('{"id":17592186873228,"name":"","email":"new@example.com","web-token":"142knb7121o0n0cvu7ho0uet0ah25leo9iokea3eki7o3ngarlu9","agent-token":"1itfk3sfeudtj1tj0vmkkcbemalgjv4bi3rrkl84he86h78rrnmk"}')
      Canary.stubs(:new).with(anything).returns(client)
    end


    it "should let users unsubscribe" do
      login_user(user)

      ut = mock()
      ut.expects(:untag)
      OurIntercom.expects(:tags).returns(ut)

      put :update, :user => { :newsletter_email_consent => false }

      user.reload
      assert_equal user.newsletter_email_consent, false
    end

    it "should let users subscribe" do
      login_user(user)

      t = mock()
      t.expects(:tag)
      OurIntercom.expects(:tags).returns(t)

      put :update, :user => { :daily_email_consent => true}

      user.reload
      assert_equal user.daily_email_consent, true
    end

    it "should not reissue API requests if nothing changed" do
      login_user(user)

      ut = mock()
      ut.stubs(:untag).never
      OurIntercom.stubs(:tags).returns(ut)

      t = mock()
      t.stubs(:tag).never
      OurIntercom.stubs(:tags).returns(t)

      put :update, :user => { :daily_email_consent => false,
                               :newsletter_email_consent => true}
    end
  end


   it "users changing their email should fail gracefully" do
    login_user(user)

    new_email = "new@example.com"

    client = mock
    client.expects(:update_user).with(anything).raises(Faraday::Error, "lol nope")
    client.expects(:me).with(anything).returns({"agent-token": "test"})
    client.stubs(:servers).returns({})
    Canary.stubs(:new).with(anything).returns(client)

    put :update, :user => { :email => new_email }

    assert user.errors["email"].present?

    user.reload
    assert_not_equal user.email, new_email
  end

end
