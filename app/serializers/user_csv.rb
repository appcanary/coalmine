require 'csv'
class UserCSV
  def initialize(collection)
    @collection = collection
  end

  def template
    [:email,
     :name,
     :servers_count,
     :active_servers_count,
     :created_at,
     :beta_signup_source]
  end

  def map(u)
    template.map do |sym|
      u.send(sym)
    end
  end

  def to_csv
    CSV.generate do |csv| 
      @collection.each do |u| 
        csv << map(u)
      end
    end
  end

  def write!
    filename = File.join("/tmp/", "#{Time.now.iso8601}.csv")
    File.write(filename, to_csv)
    puts filename
  end
end
