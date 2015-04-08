namespace :webpack do
  desc 'compile webpack bundle'
  task :compile do
    cmd = 'npm run webpack-bundle'
    puts `#{cmd}`

    if $?.exitstatus > 0
      raise "webpack failed"
    end
  end
end
