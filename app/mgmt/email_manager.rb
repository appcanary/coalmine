class EmailManager < ServiceManager
=begin
SELECT
    "accounts". ID,
    log_bundle_vulnerability_id
FROM "accounts"
INNER JOIN(
    SELECT
        bundles.account_id,
        log_bundle_vulnerabilities. ID log_bundle_vulnerability_id
    FROM log_bundle_vulnerabilities
    INNER JOIN "bundles" ON "bundles"."id" = "log_bundle_vulnerabilities"."bundle_id"
    LEFT JOIN notifications ON log_bundle_vulnerability_id = log_bundle_vulnerabilities.id
    WHERE notifications.id IS NULL
) unnotified_vuln_bundles ON accounts. ID = unnotified_vuln_bundles.account_id
=end
  def self.queue_vuln_email
    Account.transaction do
      emails_to_send = Account.select("accounts.id, log_bundle_vulnerability_id").from('"accounts" INNER JOIN (select bundles.account_id, log_bundle_vulnerabilities.id log_bundle_vulnerability_id from log_bundle_vulnerabilities inner join "bundles" ON "bundles"."id" = "log_bundle_vulnerabilities"."bundle_id" where log_bundle_vulnerabilities.id not in (select log_bundle_vulnerability_id from notifications)) unnotified_vuln_bundles ON accounts.id = unnotified_vuln_bundles.account_id').pluck("id, log_bundle_vulnerability_id").reduce({}) { |hsh, (a_id, lbv)|
        hsh[a_id] ||= []
        hsh[a_id] << lbv
        hsh
      }

      emails_to_send.each_pair do |aid, lbvs|
        email = EmailVulnerable.create!(:account_id => aid)

        lbvs.each do |lid|
          Notification.create!(:email_message_id => email.id,
                           :log_bundle_vulnerability_id => lid)

        end
      end
    end
  end
end
