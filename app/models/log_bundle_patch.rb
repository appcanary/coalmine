# == Schema Information
#
# Table name: log_bundle_patches
#
#  id                    :integer          not null, primary key
#  bundle_id             :integer
#  package_id            :integer
#  bundled_package_id    :integer
#  vulnerability_id      :integer
#  vulnerable_package_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class LogBundlePatch < ActiveRecord::Base
  belongs_to :bundle
  belongs_to :vulnerable_package

  # Every time a bundle is changed, note whether
  # the bundle is *no longer* vulnerable to a vuln
  # at that point in time.
  #
  # We create a log instances whenever:
  # 1. A bundle is updated, and is no longer vuln
  # 2. Vulnerability that affects a package in bundle gets deleted
  # 3. Vulnerability that affects a package is edited, & package no longer affected

end
