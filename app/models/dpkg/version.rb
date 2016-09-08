module Dpkg
  # The code below is a java port of the c code from lib/dpkg/version.c (git://anonscm.debian.org/dpkg/dpkg.git rev: 177d85ef4ed54fabf60cc2ff1e9e8c5a5b4ff604)
  module Version

    def self.parse(str)
      str = str.strip
      epoch, version, revision = nil

      if str.blank?
        raise ArgumentError.new("Empty version string: #{str}")
      end

      if str =~ /\s/
        raise ArgumentError.new("Version string has embedded spaces: #{str}")
      end


      vrstr = str
      if str.index(":")
        estr, vrstr = str.split(":", 2)

        if vrstr.blank?
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

      lstr, hyphen, rstr = vrstr.rpartition("-")
      # rpartition returns leftmost, match, rightmost
      # if no match, both match and leftmost are ""
      if lstr.empty?
        version = rstr
      else
        version = lstr
        revision = rstr
      end

      if !(version[0] =~ /\d/)
        raise ArgumentError.new("version does not start with digit: #{str}")
      else

        if version =~ /[^0-9a-zA-Z.\-+~:]/
          raise ArgumentError.new("Invalid character in version number: #{str}")
        end

        if revision && revision =~ /[^0-9a-zA-Z.\-+~:]/
          raise ArgumentError.new("Invalid character in revision number: #{str}")
        end

        [epoch, version, revision]
      end
    end


    def self.is_digit?(str)
      /\A[+-]?\d+\z/ === str.to_s
    end

    def self.is_alpha?(str)
      /\A[a-zA-Z]\z/ === str.to_s
    end

    def self.order(char)
      # catchall nil check
      if char.nil?
        return 0
      elsif is_digit?(char)
        return 0
      elsif is_alpha?(char)
        return char.bytes.first
      elsif char == "~"
        return -1
        # I think purpose here is to weigh non alpha
        # chars more highly 
      elsif (c = char.bytes.first) != 0
        return c + 256
      else
        return 0
      end
    end

    def self.verrevcmp(stra = "", strb = "")
      achars = stra.chars
      bchars = strb.chars

      a = achars.shift
      b = bchars.shift
      while(a || b)
        first_diff = 0

        while(a && !is_digit?(a) || b && !is_digit?(b))

          ac = order(a)
          bc = order(b)

          if ac != bc
            return ac - bc
          end

          a = achars.shift
          b = bchars.shift
        end

        while(a == '0') 
          a = achars.shift
        end

        while(b == '0')
          b = bchars.shift
        end

        while(is_digit?(a) && is_digit?(b)) 
          if first_diff != 0
            first_diff = a <=> b
          end
          a = achars.shift
          b = bchars.shift
        end

        if is_digit?(a)
          return 1
        end

        if is_digit?(b)
          return -1
        end

        if first_diff != 0
          return first_diff
        end
      end

      return 0
    end

=begin
// version.c

static int
order(int c)
{
	if (c_isdigit(c))
		return 0;
	else if (c_isalpha(c))
		return c;
	else if (c == '~')
		return -1;
	else if (c)
		return c + 256;
	else
		return 0;
}

static int
verrevcmp(const char *a, const char *b)
{
	if (a == NULL)
		a = "";
	if (b == NULL)
		b = "";

	while (*a || *b) {
		int first_diff = 0;

		while ((*a && !c_isdigit(*a)) || (*b && !c_isdigit(*b))) {
			int ac = order(*a);
			int bc = order(*b);

			if (ac != bc)
				return ac - bc;

			a++;
			b++;
		}
		while (*a == '0')
			a++;
		while (*b == '0')
			b++;
		while (c_isdigit(*a) && c_isdigit(*b)) {
			if (!first_diff)
				first_diff = *a - *b;
			a++;
			b++;
		}

		if (c_isdigit(*a))
			return 1;
		if (c_isdigit(*b))
			return -1;
		if (first_diff)
			return first_diff;
	}

	return 0;
}
=end

  end
end
