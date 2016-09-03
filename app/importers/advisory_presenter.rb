# the job of advisory presenters is to
# intermediate between the raw parsed output
# of our importer content, and the specific
# structure we hold in our advisories.
#
# This way FooImporter dumps a hash into FooAdvisoryPresenter
# and then FooAdvisoryPresenter creates its corresponding Advisory
# Not totally unrelated from Form objects, really.
class AdvisoryPresenter < Struct
  attr_accessor :source_text
  def initialize(hsh, source_text = nil)
    @source_text = source_text
    super *members.map{|k| hsh[k.to_s] }
  end

  def to_advisory_attributes
    Hash[advisory_keys.map { |k| 
      if self.respond_to?("generate_#{k}")
        [k, send("generate_#{k}")] 
      else
        [k, send(k)]
      end
    }]
  end

  def advisory_keys
    raise NotImplementedError.new("this sould be subclassed")
  end
end
