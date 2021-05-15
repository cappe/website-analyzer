class LighthouseReporter
  class ParallelRunner
    attr_accessor :url,
                  :website,
                  :root_dir

    def initialize(url:, website:)
      self.url = url
      self.website = website
      self.root_dir = "#{Rails.root}/websites/#{website}"

      unless Dir.exist?(self.root_dir)
        FileUtils.mkdir_p(self.root_dir)
      end
    end

    def call
      puts "Saving sitemaps...".blue

      sitemap = SaveSitemap.call(
        url: url,
        root_dir: root_dir,
        sitemap_format: :json
      )

      # sitemap = "#{self.root_dir}/sitemap.json"

      puts "Running Lighthouse...".blue
      reports_dir = ParallelAnalyzer.call(
        sitemap: sitemap,
        root_dir: root_dir
      )

      # reports_dir = "#{root_dir}/parallel_reports"

      # puts "Writing Excel...".blue
      WriteParallelSummaryReport.call(
        reports_dir: reports_dir,
        root_dir: root_dir
      )

      puts "Done!".green
    end
  end
end
