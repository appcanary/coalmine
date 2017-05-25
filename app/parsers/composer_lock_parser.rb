class ComposerLockParser
  include ResultObject

  # As far as I can make out, the composer.lock file does *not* lock transitive
  # dependencies. This means that we will only assemble top level dependency
  # versions here. TODO: perhaps we can make some assumptions based on the
  # constraints found in the `requires` key in the package map. This is not
  # trivial however, as those constraints define ranges of possibilities for
  # what *might* be installed, so the confidence of any report would be low.
  def self.parse(composelock)
    data = JSON.parse(composelock)
    # TODO: how much do we care about `packages-dev` really?
    pkgs = data["packages"].concat(data["packages-dev"]).map { |ph|
      Parcel::Composer.new(ph)
    }
    Result.new(pkgs, nil)
  rescue Exception => e
    Result.new(nil, e)
  end
end
