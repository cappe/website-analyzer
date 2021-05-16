class LighthouseReporter
  class ParallelRunner
    attr_accessor :url,
                  :website,
                  :root_dir,
                  :workers

    def initialize(url:, website:, **options)
      self.url = url
      self.website = website
      self.root_dir = "#{Rails.root}/websites/#{website}/#{DateTime.now.strftime('%d_%m_%Y_%H:%M')}/parallel"
      # self.root_dir = "#{Rails.root}/websites/#{website}/16_05_2021_14:38/parallel"
      self.workers = options[:workers]

      unless Dir.exist?(self.root_dir)
        FileUtils.mkdir_p(self.root_dir)
      end
    end

    def call
      puts "Saving sitemaps...".blue
      SaveSitemap.call(
        url: url,
        root_dir: root_dir,
        sitemap_format: :json
      )

      puts "Running Lighthouse...".blue
      ParallelAnalyzer.call(
        root_dir: root_dir,
        workers: workers
      )

      puts "Writing Excel...".blue
      WriteParallelSummaryReport.call(
        root_dir: root_dir
      )

      puts "Done!".green
    end
  end
end
