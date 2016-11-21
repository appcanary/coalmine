class EmailsController < ApplicationController
  def index
    @patch_emails = current_user.account.email_patcheds
    @vuln_emails = current_user.account.email_vulnerables
  end

  def show
    @email = current_user.account.email_messages.find(params[:id])
    @notifier = NotificationPresenter.new(@email)
    case @email
    when EmailPatched
      render "notification_mailer/patched_email"
    when EmailVulnerable
      render "notification_mailer/vulnerable_email"
    end
  end
end
