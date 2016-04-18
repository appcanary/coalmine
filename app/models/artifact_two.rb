class ArtifactTwo < ApiBase
  def kind_pretty
    if kind =~ /rubygem/
      "rubygem"
    else
      kind
    end
  end
end
