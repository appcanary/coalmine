module Dpkg
  # The code below is a java port of the c code from lib/dpkg/version.c (git://anonscm.debian.org/dpkg/dpkg.git rev: 177d85ef4ed54fabf60cc2ff1e9e8c5a5b4ff604)
  module Version
    def is_digit?(str)
      /\A[+-]?\d+\z/ === str.to_s
    end

    def is_alpha?(str)
      /\A[a-zA-Z]\z/ === str.to_s
    end

    def order(char)
      if is_digit?(char)
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

    def verrevcmp(stra = "", strb = "")
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

  end
end
