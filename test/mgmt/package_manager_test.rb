require 'test_helper'

class PackageManagerTest < ActiveSupport::TestCase
  describe "a package is the tuple (platform, release, name, version)" do
    it "we should find or create packages accordingly" do
      p1 = FactoryGirl.create(:package, :ruby)
      p2 = {:name => "foobarbaz", 
            :version => "1.0.0", :platform => "ruby"}

      package_list = [p2, {:name => p1.name, :version => p1.version}]

      assert_equal 1, Package.count

      @pm = PackageMaker.new("ruby", nil)
      packages = @pm.find_or_create(package_list.map { |h| Package.new(h)})
      assert_equal 2, packages.count
      assert_equal 2, Package.count

      #  TODO only some types are allowed to have blank release
    end


    it "should find just the relevant packages" do
      pkg1, pkg2, _ = FactoryGirl.create_list(:package, 10, :ubuntu)
      mislead_pkg = FactoryGirl.create(:package, :ruby,
                                       :name => pkg1.name,
                                       :version => pkg1.version)
      plist = [{:name => pkg1.name,
                :version => pkg1.version},
                {:name => pkg2.name,
                 :version => pkg2.version,
                 :platform => pkg2.platform}].map { |h| Package.new(h) }
      @pm = PackageMaker.new(pkg1.platform, pkg1.release)
      list = @pm.find_existing_packages(plist)

      assert_equal 2, list.count

      assert_equal pkg1.id, list.first.id
      assert_equal pkg2.id, list.second.id

      plist2 = [{:name => pkg1.name + "lol",
                 :version => pkg1.version },
                 {:name => pkg2.name,
                  :version => pkg2.version}].map { |h| Package.new(h) }

      list = @pm.find_existing_packages(plist2)

      assert_equal 1, list.count
      assert_equal pkg2.id, list.first.id
    end

    it "should create new packages only when appropriate" do
      p1, p2, p3, _ = FactoryGirl.create_list(:package, 10, :ubuntu)
      
      assert_equal 10, Package.count

      @pm = PackageMaker.new(p1.platform, p1.release)

      # build a query pointing to only two packages that already exist,
      # tho it has multiple instances of each
      package_list = [p1, p2, p1]
      package_list = package_list +  [{name: "fakeMcFakerson", version: "1.2.3"},
                                      {name: "fakeMcFakerson", version: "1.2.3"}].map { |h| Package.new(h) }

      existing_query = @pm.find_existing_packages(package_list)

      list = @pm.create_missing_packages(existing_query, package_list)

      # even tho we have duplicates, it only creates it once / don't raise
      # validation errors
      assert_equal 11, Package.count
      assert_equal 1, list.count
    end

    it "should create packages and update relevant vulns" do
      pkg_name = "fakemcfake"
      pkg = FactoryGirl.build(:package, :ruby, :name => pkg_name, :version => "1.0.2")
      vuln = FactoryGirl.create(:vulnerability, 
                         :deps => [pkg])

      assert_equal 0, Package.count
      assert_equal 0, vuln.packages.count
      @pm = PackageMaker.new(Platforms::Ruby, nil)

      @pm.create(:name => "fakemcfake",
                 :version => "1.0.1")

      @pm.create(:name => "fakemcfake",
                 :version => "1.0.3")

      assert_equal 2, Package.count
      assert_equal 1, vuln.packages.count
    end

    it "should return an empty list when given an empty list" do
      @pm = PackageMaker.new(Platforms::Ruby, nil)
      assert_equal [], @pm.find_or_create([])
    end
  end

   test "when a package gets created, the vulns that affect it get updated" do
    v1, v2, _ = FactoryGirl.create_list(:vulnerability, 5)

    pkg_name = v1.vulnerable_dependencies.first.package_name

    # create a vuln package; auto gen package versions
    # guaranteed to be >=1.0.0
    p1 = FactoryGirl.create(:package, :ruby,
                            :name => pkg_name,
                            :version => "0.0.1")


    assert_equal 0, VulnerablePackage.count
    assert_equal 1, Package.count
    ActiveRecord::Base.transaction do
      PackageMaker.new("irrelephant", "nope").add_package_to_affecting_vulnerabilities!(VulnerableDependency.all, p1)
    end

    v1.reload
    assert_equal 1, VulnerablePackage.count
    assert v1.packages.include?(p1)
  end


end
