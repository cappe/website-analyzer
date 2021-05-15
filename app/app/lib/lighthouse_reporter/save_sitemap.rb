require 'open-uri'

class LighthouseReporter
  class SaveSitemap
    include Callable

    attr_accessor :url,
                  :root_dir,
                  :sitemap_writer

    def initialize(url:, root_dir:, sitemap_format:)
      self.url = url
      self.root_dir = root_dir
      self.sitemap_writer = LighthouseReporter
                              .const_get("SitemapAs#{sitemap_format.to_s.camelcase}")
                              .new(root_dir: root_dir)
    end

    def index_sitemap
      @index_sitemap ||= Nokogiri::HTML(open(self.url))
    end

    def sitemaps
      @sitemaps ||= index_sitemap.xpath("//loc").map do |loc|
        loc.children.to_s
      end
    end

    def call
      page_urls = sitemaps.map do |sitemap_url|
        sitemap_doc = Nokogiri::HTML(open(sitemap_url))
        sitemap_doc.xpath("//url/loc").map do |loc|
          loc.children.to_s
        end
      end.flatten

      self.sitemap_writer.write page_urls
    end
  end
end
