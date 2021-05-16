namespace :analyzer do
  desc 'Analyzes a given website and generates an Excel summary for it'
  task run: :environment do
    name = ENV['name']
    url = ENV['url']
    strategy = ENV['strategy']
    workers = ENV['workers']&.to_i

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

    if strategy == 'parallel' && (!workers || workers <= 0)
      puts "workers number not set, exiting...".red
      exit
    end

    runner = LighthouseReporter
               .const_get("#{strategy.to_s.camelcase}Runner")
               .new(
                 url: url,
                 website: name,
                 workers: workers,
               )

    LighthouseReporter.call(
      runner: runner
    )
  end
end
