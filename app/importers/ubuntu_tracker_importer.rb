class UbuntuTrackerImporter < AdvisoryImporter
  SOURCE = "ubuntu-tracker"
  REPO_URL = "https://launchpad.net/ubuntu-cve-tracker"
  REPO_PATH = "tmp/importers/ubuntu-cve-tracker"

  PATCHES_REGEX= /^(?<release>[a-z].*)_(?<package>.*?): (?<status>[^\s]+)( \(+(?<note>[^()]*)\)+)?/

  def initialize(repo_path = nil)
    @repo_path = repo_path || REPO_PATH
    @repo_url = REPO_URL
  end

  def local_path
    File.join(Rails.root, @repo_path)
  end

  def update_local_store!
    bzr = BzrHandler.new(self.class, @repo_url, local_path)
    bzr.fetch_and_update_repo!
  end

  def fetch_advisories
    Dir[File.join(local_path, "{active,retired}", "/CVE*")]
  end

  def parse(cve_file)
    lines = File.read(cve_file).lines
    hsh = {}

    still_parsing = true
    while still_parsing
      cur_line = lines.shift

      # stop if we're out of lines
      if cur_line.nil?
        still_parsing = false
        next
      end

      # ignore comments, empty lines
      if cur_line.starts_with?("#") || cur_line.blank?
        next
      end

      # well, what if it's a Patches line?
      if cur_line.starts_with?("Patches")
        still_parsing = false
        # the description part of the file has ended
        # and all that remains are patches, so
        # jump to this other parser:
        hsh = parse_patches_section(hsh, lines)
        next
      end

      # are we dealing with a key/value?

      # a key doesn't begin with a space
      unless cur_line.starts_with?(" ")
        k, v = cur_line.split(":")

        if v.present?
          hsh[k.downcase.underscore] = v.strip
          next
        end
      end


      # if we're executing this far:
      # We're not a single line key/value
      # We're not yet in a Patches section.
      #
      # There may be values on the following lines
      values = []

      # so, let's lookahead
      next_line = lines.first

      while next_line.starts_with?(" ")
        # pop the next_line from the lines 'stack'
        lines.shift 
        values << next_line.strip

        # lookahead to the next line, which may
        # be nil
        next_line = (lines.first || "")
      end

      if values.present?
        hsh[k.downcase.underscore] = values
      else
        hsh[k.downcase.underscore] = nil
      end
    end

    UbuntuTrackerAdvisory.new(hsh)
  end

  def parse_patches_section(hsh, lines)
    
    while !(cur_line = lines.shift).nil?

      if (matches = cur_line.match(PATCHES_REGEX))
        _, release, package, status, notes = matches.to_a

        hsh["patches"] ||= []
        o = {"release" => release, 
             "package" => package, 
             "status" => status, 
             "notes" => notes}
        hsh["patches"] << o
      end
    end

    hsh
  end

end
