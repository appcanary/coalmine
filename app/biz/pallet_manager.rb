class PalletManager
  attr_accessor :account
  def initialize(account)
    @account = account
  end

  def create(opt = {}, package_list)
    pallet = Pallet.new(:account_id => @account.id,
                        :kind => opt[:kind],
                        :release => opt[:release],
                        :name => opt[:name],
                        :path => opt[:path],
                        :last_crc => opt[:last_crc],
                        :from_api => opt[:from_api])


    unless pallet.save
      return [pallet, pallet.errors]
    end

    packages = PackageManager.parse_list(kind, release, package_list)

    return set_packages(pallet, packages)
  end

  def update(pallet, package_list)
    packages = PackageManager.parse_list(pallet.kind, pallet.release, package_list)

    return set_packages(pallet, packages)
  end

  def create_revision!(pallet, packages)
    # eh tbd
  end

  def set_packages(pallet, packages)
    create_revision!(pallet, packages)

    # todo, do this in a way that calcs if vuln
    # this will auto create PackageSets
    pallet.packages = packages

    # pallet.package_sets = packages.map do |p| 
    #   PackageSet.new(:package_id => p.id,
    #                  :vulnerability => p.vulnerable?)
    # end

    [pallet, pallet.errors]
  end
end
