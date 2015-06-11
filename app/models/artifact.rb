class Artifact < CanaryBase

  attr_params :id, :name, :kind, :uuid, :authors, :description, :uri, :vulnerability, 

  def kind
    if @kind["ident"] =~ /rubygem/
      "rubygem"
    else
      @kind["ident"]
    end
  end
end
