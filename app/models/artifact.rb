class Artifact < CanaryBase

  attr_params :id, :name, :kind, :uuid, :authors, :description, :uri, :vulnerability, 

  def kind
    if @kind =~ /rubygem/
      "rubygem"
    else
      @kind
    end
  end
end
