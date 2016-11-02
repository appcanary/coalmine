class Admin::EmailsController < AdminController
  def index
    if current_user.is_admin?
      @patch_emails = EmailPatched.order("sent_at desc").paginate(:page => params[:page])
      @vuln_emails = EmailVulnerable.order("sent_at desc").paginate(:page => params[:page]).per_page(100)

    else
      @patch_emails = current_user.account.email_patcheds
      @vuln_emails = current_user.account.email_vulnerables
    end
  end

  def show
    if current_user.is_admin?
      @email = EmailMessage.find(params[:id])
    else
      @email = current_user.account.email_messages.find(params[:id])
    end
    @notifier = NotificationPresenter.new(@email)
    case @email
    when EmailPatched
      render "notification_mailer/patched_email"
    when EmailVulnerable
      render "notification_mailer/vulnerable_email"
    end
  end
end
