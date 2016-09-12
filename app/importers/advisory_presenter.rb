# the job of advisory presenters is to
# intermediate between the raw parsed output
# of our importer content, and the specific
# structure we hold in our advisories.
#
# This way FooImporter dumps a hash into FooAdvisoryPresenter
# and then FooAdvisoryPresenter creates its corresponding Advisory
# Not totally unrelated from Form objects, really.
#
# USAGE:
#
# class Subclassed < Advisory.new(:field1, :field2)
#   # implement identifier, platform, source methods
#   generate :outputted_field do
#     values_here
#   end
# end
#
# s = Subclassed.new("field1" => 1, "field2" => 2)
# s.to_advisory_attributes # => {"identifier" => "", "platform" => "", 
#                          # "source" => "", "outputted_field" => values_here }

class AdvisoryPresenter < Struct

  class << self
    attr_accessor :generators
    def generate(name, &block)
      @generators ||= {}
      @generators[name] = block
    end
  end

  def initialize(hsh, source_text = nil)
    @_source_text = source_text
    super *members.map{|k| hsh[k.to_s] }
  end

  def to_advisory_attributes
    # take all the generated attributes
    # and merge with the mandatory ones
    self.class.generators.reduce({}) do |acc, (name, blk)|
      acc[name.to_s] = self.instance_exec &blk
      acc
    end.merge({"identifier" => identifier,
               "platform" => platform,
               "source_text" => @_source_text,
               "source" => source})
  end

end
