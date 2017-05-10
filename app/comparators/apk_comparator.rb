class ApkComparator
  attr_accessor :version

  PRE_SUFFIXES = %w{alpha beta pre rc}
  POST_SUFFIXES = %w{cvs svn git hg p}
  PARTS = %i{invalid digit_or_zero digit letter suffix suffix_no revision_no end}

  def initialize(version_str)
    self.version = version_str
  end

  def satisfies?(constraint)
    self.vercmp(version, constraint) >= 0
  end

  # This code is an approximate port of the C version implemented in the
  # apk-tools package. That's found in `version.c`, here:

  #   https://git.alpinelinux.org/cgit/apk-tools/tree/src/version.c

  def vercmp(v1, v2)
    return 0 if v1 == v2 || (v1.blank? && v2.blank?)

    if v1.blank? || v2.blank?
      raise "v1 (#{v1}) isn't greater than, equal to or less than v2 (#{v2}) ¯\\_(ツ)_/¯"
    end

    av = 0
    bv = 0

    vs1 = VersionState.new(v1)
    vs2 = VersionState.new(v2)

    while vs1.type == vs2.type && vs1.type != :end && vs1.type != :invalid && av == bv
      av = get_token(vs1)
      bv = get_token(vs2)
    end

    # value of the current token differs?
    return -1 if av < bv
    return 1 if av > bv

    # both have :end or :invalid next?
    return 0 if vs1.type == vs2.type

    # leading version components and their values are equal, now the
    # non-terminating version is greater unless it's a suffix indicating
    # pre-release
    return -1 if vs1.type == :suffix && get_token(vs1) < 0
    return 1 if vs2.type == :suffix && get_token(vs2) < 0

    return -1 if part(vs1.type) > part(vs2.type)
    return 1 if part(vs2.type) > part(vs1.type)

    return 0
  end

  def valid?(ver)
    vs = VersionState.new(ver)

    loop do
      get_token(vs)
      break if vs.type == :end || vs.type == :invalid
    end

    vs.type == :end
  end

  private
  VersionState = Struct.new(:type, :version_str, :current_idx) do
    def initialize(version_str)
      self.type = :digit
      self.version_str = version_str
      self.current_idx = 0
    end

    def remaining_len
      version_str.size - current_idx
    end
  end

  def is_digit?(s)
    true if Integer(s) rescue false
  end

  def find_index(arr, vs, idx)
    arr.find_index { |s| vs.version_str[idx..-1].start_with?(s) }
  end

  def is_lower?(s)
    !!s.match(/\p{Lower}/)
  end

  def part(p)
    PARTS.find_index(p) - 1
  end

  def get_token(vs)
    if vs.remaining_len <= 0
      vs.type = :end
      return 0
    end

    nt = :invalid
    i = vs.current_idx
    v = 0

    read_digit = -> {
      while i < vs.version_str.size && is_digit?(vs.version_str[i])
        v *= 10;
        v += vs.version_str[i].to_i
        i += 1
      end
    }

    case vs.type
    when :digit_or_zero
      if vs.version_str[i] == '0'
        while i < vs.version_str.size && vs.version_str[i] == '0'
          i += 1
        end
        nt = :digit
        v = -1
      else
        read_digit.call
      end
    when :digit, :suffix_no, :revision_no
      read_digit.call
    when :letter
      v = vs.version_str[i]
      i += 1
    when :suffix
      v = find_index(PRE_SUFFIXES, vs, i)
      if v.present?
        i += PRE_SUFFIXES[v].size
        v -= PRE_SUFFIXES.count
      else
        v = find_index(POST_SUFFIXES, vs, i)
        i += POST_SUFFIXES[v].size
        if v.nil?
          vs.type = :invalid
          return -1
        end
      end
    else
      vs.type = :invalid
      return -1
    end

    vs.current_idx = i

    if vs.remaining_len == 0
      vs.type = :end
    elsif nt != :invalid
      vs.type = nt
    else
      next_token(vs)
    end

    v
  end

  def next_token(vs)
    n = :invalid

    if vs.remaining_len == 0
      n = :end
    elsif (vs.type == :digit || vs.type == :digit_or_zero) &&
          is_lower?(vs.version_str[vs.current_idx])
      n = :letter
    elsif vs.type == :letter && is_digit?(vs.version_str[vs.current_idx])
      n = :digit
    elsif vs.type == :suffix && is_digit?(vs.version_str[vs.current_idx])
      n = :suffix_no
    else
      case vs.version_str[vs.current_idx]
      when '.'
        n = :digit_or_zero
      when '_'
        n = :suffix
      when '-'
        if vs.remaining_len > 1 && vs.version_str[vs.current_idx + 1] == 'r'
          n = :revision_no
          vs.current_idx += 1
        else
          n = :invalid
        end
      end

      vs.current_idx += 1
    end

    if part(n) < part(vs.type)
      if not ((n == :digit_or_zero && vs.type == :digit) ||
              (n == :suffix && vs.type == :suffix_no) ||
              (n == :digit && vs.type == :letter))
        n = :invalid
      end
    end

    vs.type = n
  end
end
