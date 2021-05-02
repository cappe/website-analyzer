require 'open-uri'

class LighthouseReporter
  class SaveSitemap
    include Callable

    attr_accessor :url,
                  :dest_path

    def initialize(url:, dest_path:)
      self.url = url
      self.dest_path = dest_path
    end

    def index_sitemap
      @index_sitemap ||= Nokogiri::HTML(open(self.url))
    end

    def sitemaps
      @sitemaps ||= index_sitemap.xpath("//loc").map do |loc|
        loc.children.to_s
      end
    end

    def dest
      "#{dest_path}/sitemap.txt"
    end

    def call
      page_urls = sitemaps.map do |sitemap_url|
        sitemap_doc = Nokogiri::HTML(open(sitemap_url))
        sitemap_doc.xpath("//url/loc").map do |loc|
          loc.children.to_s
        end
      end.flatten

      File.open(dest, 'w') { |f| f.puts(page_urls) }

      dest
    end
  end
end
