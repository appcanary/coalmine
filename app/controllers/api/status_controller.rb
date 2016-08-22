class Api::StatusController < ApiController
  LOGO = File.read(File.join(Rails.root, "lib/assets", "logo.ascii"))
  def status
    render :text => LOGO
  end

end
