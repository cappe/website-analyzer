class LighthouseReporter
  class SitemapAsJson
    attr_accessor :root_dir

    def initialize(root_dir:)
      self.root_dir = root_dir
    end

    def dest_path
      "#{root_dir}/sitemap.json"
    end

    def write(urls)
      json_urls = urls.map do |url|
        [
          {
            Device: 'mobile',
            URL: url
          },
          {
            Device: 'desktop',
            URL: url
          }
        ]
      end.flatten.to_json

      File.open(dest_path, 'w') { |f| f.puts(json_urls) }
    end
  end
end
