module FactoryHelper

  def self.rand_version_str
    "#{rand(1..10)}.#{rand(10)}.#{rand(10)}"
  end

  def self.rand_platform
    ["ruby", "ubuntu"].sample 
  end

end
