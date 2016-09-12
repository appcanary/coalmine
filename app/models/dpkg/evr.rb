module Dpkg
  class Evr
    attr_reader :epoch, :version, :revision

    def self.from_s(str)
      epoch, version, revision = Dpkg::Version.parse(str)
      self.new(epoch, version, revision)
    end

    def initialize(epoch = nil, version = nil, revision = nil)
      @epoch = epoch || 0
      @version = version
      @revision = revision
    end

    def <=>(b)
      if self.epoch > b.epoch
        return 1
      end

      if self.epoch < b.epoch
        return -1
      end

      rc = Dpkg::Version.verrevcmp(self.version, b.version)
      if rc != 0
        return rc;
      end

      return Dpkg::Version.verrevcmp(self.revision, b.revision)
    end
  end

=begin
version.c

int
dpkg_version_compare(const struct dpkg_version *a,
                     const struct dpkg_version *b)
{
	int rc;

	if (a->epoch > b->epoch)
		return 1;
	if (a->epoch < b->epoch)
		return -1;

	rc = verrevcmp(a->version, b->version);
	if (rc)
		return rc;

	return verrevcmp(a->revision, b->revision);
}
=end
end
