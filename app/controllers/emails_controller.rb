class EmailsController < ApplicationController
  def index
    @patch_emails = current_user.account.email_patcheds.order("sent_at desc")
    @vuln_emails = current_user.account.email_vulnerables.order("sent_at desc")
  end

  def show
    @email = current_user.account.email_messages.find(params[:id])
    @notifier = NotificationPresenter.new(@email)
  end
end
