class LighthouseReporter
  class LighthouseRunner
    include Callable

    attr_accessor :sitemap_path,
                  :dest_path

    def initialize(sitemap_path:, dest_path:)
      self.sitemap_path = sitemap_path
      self.dest_path = "#{dest_path}/lighthouse"

      unless Dir.exist?(self.dest_path)
        FileUtils.mkdir_p(self.dest_path)
      end
    end

    def command
      "lighthouse-batch -v -f #{sitemap_path} -o #{dest_path}"
    end

    def call
      system(command)
      exit_code = $?.exitstatus

      raise "exit #{exit_code}" unless exit_code == 0

      # "#{self.dest_path}/summary.json"
      self.dest_path
    end
  end
end
