class BundlePatch < ActiveRecord::Base
  belongs_to :bundle_id
  belongs_to :vulnerable_package_id
end
