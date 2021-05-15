class LighthouseReporter
  class SitemapAsTxt
    attr_accessor :root_dir

    def initialize(root_dir:)
      self.root_dir = root_dir
    end

    def dest_path
      "#{root_dir}/sitemap.txt"
    end

    def write(urls)
      File.open(dest_path, 'w') { |f| f.puts(urls) }
      dest_path
    end
  end
end
