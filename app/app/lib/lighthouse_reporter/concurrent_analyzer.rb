class LighthouseReporter
  class ConcurrentAnalyzer
    include Callable

    attr_accessor :sitemap,
                  :dest_dir

    def initialize(root_dir:, sitemap:)
      self.dest_dir = "#{root_dir}/concurrent_reports"
      self.sitemap = sitemap

      unless Dir.exist?(self.dest_dir)
        FileUtils.mkdir_p(self.dest_dir)
      end
    end

    def command
      "lighthouse-batch -v -f #{sitemap} -o #{dest_dir}"
    end

    def call
      system(command)
      exit_code = $?.exitstatus

      raise "exit #{exit_code}" unless exit_code == 0

      self.dest_dir
    end
  end
end
