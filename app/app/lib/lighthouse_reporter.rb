# require 'lighthouse_reporter/generate_summary'
require 'fileutils'

class LighthouseReporter
  include Callable

  attr_accessor :url,
                :website,
                :root_path

  def initialize(url:, website:)
    self.url = url
    self.website = website
    self.root_path = "#{Rails.root}/reports/#{website}"

    unless Dir.exist?(self.root_path)
      FileUtils.mkdir_p(self.root_path)
    end
  end

  def call
    puts "Saving sitemaps...".blue
    sitemap_path = SaveSitemap.call(
      url: url,
      dest_path: root_path
    )

    puts "Running Lighthouse...".blue
    summary_json_path = LighthouseRunner.call(
      sitemap_path: sitemap_path,
      dest_path: root_path
    )

    puts "Writing Excel...".blue
    GenerateSummary.call(
      source_path: summary_json_path,
      dest_path: root_path
    )

    puts "Done!".green
  end
end
