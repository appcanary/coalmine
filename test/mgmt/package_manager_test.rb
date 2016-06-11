require 'test_helper'

class PackageManagerTest < ActiveSupport::TestCase
  describe "a package is the tuple (platform, release, name, version)" do
    it "we should find or create packages accordingly" do
      p1 = FactoryGirl.create(:ruby_package)
      p2 = {:name => "foobarbaz", :kind => "rubygem", 
            :version => "1.0.0", :platform => "ruby"}

      package_list = [p2, {:name => p1.name, :version => p1.version}]

      assert_equal 1, Package.count

      @pm = PackageManager.new("ruby", nil)
      packages = @pm.find_or_create(package_list)
      assert_equal 2, packages.count
      assert_equal 2, Package.count

      #  TODO only some types are allowed to have blank release
    end


    it "should find just the relevant packages" do
      pkg1, pkg2, _ = FactoryGirl.create_list(:ubuntu_package, 10)
      mislead_pkg = FactoryGirl.create(:ruby_package, 
                                       :name => pkg1.name,
                                       :version => pkg1.version)

      @pm = PackageManager.new(pkg1.platform, pkg1.release)
      list = @pm.find_existing_packages([{:name => pkg1.name,
                                          :version => pkg1.version},
                                          {:name => pkg2.name,
                                           :version => pkg2.version,
                                           :platform => pkg2.platform}])


      assert_equal 2, list.count

      assert_equal pkg1.id, list.first.id
      assert_equal pkg2.id, list.second.id

      list = @pm.find_existing_packages([{:name => pkg1.name + "lol",
                                          :version => pkg1.version },
                                          {:name => pkg2.name,
                                           :version => pkg2.version}])

      assert_equal 1, list.count
      assert_equal pkg2.id, list.first.id
    end

    it "should know how to create only packages that we don't already have" do
      p1, p2, p3, _ = FactoryGirl.create_list(:ubuntu_package, 10)
      
      assert_equal 10, Package.count

      @pm = PackageManager.new(p1.platform, p1.release)

      # build a query pointing to only two packages
      package_list = [p1, p2].map { |p| {name: p.name, version: p.version}}
      existing_query = @pm.find_existing_packages(package_list)

      # add two packages: one that already exists, one we already have
      # a copy of, and a brand new one
      package_list = package_list +  [{name: p1.name, version: p1.version},
                                      {name: p3.name, version: p3.version},
                                      {name: "fakeMcFakerson", version: "1.2.3"}]

      list = @pm.create_missing_packages(existing_query, package_list)

      # TODO: decide if this is OK behaviour; the names supplied in
      # package_list are not *supposed* to change, but if they do,
      # there is no validation
      assert_equal 12, Package.count
      assert_equal 2, list.count
    end

    it "should create packages and update relevant vulns" do
      pkg_name = "fakemcfake"
      vuln = FactoryGirl.create(:vulnerability, 
                         :package_name => pkg_name,
                         :package_platform => Platforms::Ruby,
                         :patched_versions => ["> 1.0.2"])

      assert_equal 0, Package.count
      assert_equal 0, vuln.packages.count
      @pm = PackageManager.new(Platforms::Ruby, nil)

      @pm.create(:name => "fakemcfake",
                 :version => "1.0.1")

      assert_equal 1, Package.count
      assert_equal 1, vuln.packages.count
    end
  end
end
