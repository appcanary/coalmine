Rake::Task["db:schema:load"].clear
namespace 'db' do
  namespace 'schema' do
    task 'load' do
      puts "NOPE"
      puts "We use triggers, which are unsupported by the ruby schema dump format. Either change it in config/application or run all migrations"
      raise SystemExit
    end
  end
end
