class Api::BundleController < ApiController

  # how do you solve a problem like error handling?
  def create
    # at the crux of it: how should managers report back
    # that something messed up?
    #
    # as used by others, managers are kind of like Mediators or
    # Service Objects or the Strategy pattern
    #
    # this manager pattern as i've been using it
    # is meant to be a little "container" of state.
    #
    # you initialize it with some trivial state,
    # and then use it to perform complicated actions
    # that fold across multiple models
    @bm = BundleManager.new(current_user)
   
    # i like the idea of the manager inputs being "dumb"
    # or trusted. we need to know the platform/release,
    # and the manager is going to assume that its been
    # validated
    environ, errors = Platforms.parse_env(params)

    if errors
      render json: errors
      return
    end

    package_list, errors = whatever
    if errors
      render json: errors
      return
    end

    bundle, errors = @bm.create(en, params)

    if errors
      render json: errors
    else
      render json: bundle
    end
  end
end
