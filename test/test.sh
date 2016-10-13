curl -H "Authorization: Token 7VEpGRpJVg13weqWLdNQQZZD"  "http://canary.dev:3000/api/v3/check?platform=centos&release=7" -X POST  -F file=@./test/data/parsers/centos-7-rpmqa.txt |jq
curl -H "Authorization: Token 7VEpGRpJVg13weqWLdNQQZZD"  "http://canary.dev:3000/api/v3/check?platform=ruby" -X POST  -F file=@./test/data/parsers/420rails.gemfile.lock |jq
curl -H "Authorization: Token 7VEpGRpJVg13weqWLdNQQZZD"  "http://canary.dev:3000/api/v3/check?platform=ubuntu&release=trusty" -X POST  -F file=@./test/data/parsers/ubuntu-trusty-dpkg-status.txt |jq
curl -H "Authorization: Token 7VEpGRpJVg13weqWLdNQQZZD"  "http://canary.dev:3000/api/v3/check?platform=debian&release=jessie" -X POST  -F file=@./test/data/parsers/debian-jessie-dpkg-status.tx |jq


curl -H "Authorization: Token 14ep54n4cmueve8uuaj21d433g423rbflsnqk8hdmledvb86cgd"  "https://appcanary.com/api/v2/check?platform=centos&release=7" -X POST  -F file=@./../../test/data/parsers/centos-7-rpmqa.txt |jq
curl -H "Authorization: Token 14ep54n4cmueve8uuaj21d433g423rbflsnqk8hdmledvb86cgd"  "https://appcanary.com/api/v2/check?platform=ubuntu&release=14.04" -X POST  -F file=@./test/data/parsers/ubuntu-trusty-dpkg-status.txt
curl -H "Authorization: Token 14ep54n4cmueve8uuaj21d433g423rbflsnqk8hdmledvb86cgd"  "https://appcanary.com/api/v2/check?platform=debian&release=8" -X POST  -F file=@./test/data/parsers/debian-jessie-dpkg-status.txt



cat dev-centos-resp.txt |jq ".data[].attributes.name"|sort|uniq > dev-centos-vuln-pkgnames.txt

cat dev-centos-resp.txt |jq ".included[].attributes.\"reference-ids\"[]" |sort|uniq > dev-centos-rhsas.txt

cat prod-centos-resp.txt |jq ".data[].attributes.name"|sort|uniq > prod-centos-vuln-pkgnames.txt
cat prod-centos-resp.txt |jq ".data[].attributes.vulnerabilities[].rhsa[]"|sort|uniq > prod-centos-rhsas.txt
