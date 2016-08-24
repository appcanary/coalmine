# thanks, http://stackoverflow.com/a/26226563/142266
class SqlCounter< ActiveSupport::LogSubscriber

  # Returns the number of database "Loads" for a given ActiveRecord class.
  def self.count(clazz)
    name = clazz.name + ' Load'
    Thread.current['log'] ||= {}
    Thread.current['log'][name] || 0
  end

  # Returns a list of ActiveRecord classes that were counted.
  def self.counted_classes
    log = Thread.current['log']
    loads = log.keys.select {|key| key =~ /Load$/ }
    loads.map { |key| Object.const_get(key.split.first) }
  end

  def self.reset_count
    Thread.current['log'] = {}
  end

  def sql(event)
    name = event.payload[:name]
    Thread.current['log'] ||= {}
    Thread.current['log'][name] ||= 0
    Thread.current['log'][name] += 1
  end
end
