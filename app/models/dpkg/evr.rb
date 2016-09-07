module Dpkg
  class Evr
    attr_accessor :epoch, :version, :revision
    def epoch
      @epoch || 0
    end

    def self.parse(str)
      str = str.strip
      epoch, version, revision = nil

      if str.blank?
        raise ArgumentError.new("Empty version string: #{str}")
      end

      if str =~ /\s/
        raise ArgumentError.new("Version string has embedded spaces: #{str}")
      end

      estr, vrstr = str.split(":", 2)
      if vrstr.nil?
        raise ArgumentError.new("Nothing after colon in version number: #{str}")
      else
        begin
          epoch = Integer(estr, 10)
        rescue ArgumentError
          raise ArgumentError.new("Epoch in version is not a number: #{str}")
        end

        if epoch < 0
          raise ArgumentError.new("Epoch in version is negative: #{str}")
        end
      end

      

    end
  end
end
