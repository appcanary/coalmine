class EmailsController < ApplicationController
  def index
    @patch_emails = current_user.account.email_patcheds.order("sent_at desc")
    @vuln_emails = current_user.account.email_vulnerables.order("sent_at desc")
  end

  def show
    @email = current_user.account.email_messages.find(params[:id])
    @notifier = NotificationPresenter.new(@email)
    # case @email
    # when EmailPatched
    #   render "notification_mailer/patched_email"
    # when EmailVulnerable
    #   render "notification_mailer/vulnerable_email"
    # end
  end
end
