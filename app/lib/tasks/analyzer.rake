namespace :analyzer do
  desc 'Analyzes a given website and generates an Excel summary for it'
  task run: :environment do
    name = ENV['name']
    url = ENV['url']
    strategy = ENV['strategy']

    unless name
      puts "name is missing, exiting...".red
      exit
    end

    unless url
      puts "url is missing, exiting...".red
      exit
    end

    unless strategy
      puts "strategy is missing, exiting...".red
      exit
    end

    runner = LighthouseReporter
               .const_get("#{strategy.to_s.camelcase}Runner")
               .new(
                 url: url,
                 website: name
               )

    LighthouseReporter.call(
      runner: runner
    )
  end
end
