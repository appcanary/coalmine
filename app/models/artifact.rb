class Artifact < CanaryBase
  attr_params :id, :number, :platform, :artifact

  attr_params :name, :kind, :uuid, :authors, :description, :uri, :vulnerability, 

  def name
    artifact.first.try(:[], "name")
  end

  def kind
    return platform if platform 
    if @kind["ident"] =~ /rubygem/
      "rubygem"
    else
      @kind["ident"]
    end
  end
end
