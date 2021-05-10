namespace :analyzer do
  desc 'Analyzes a given website and generates an Excel summary for it'
  task run: :environment do
    name = ENV['name']
    url = ENV['url']

    unless name
      puts "name is missing, exiting...".red
      exit
    end

    unless url
      puts "url is missing, exiting...".red
      exit
    end

    LighthouseReporter.call(
      url: url,
      website: name
    )
  end
end
