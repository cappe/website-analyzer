class LighthouseReporter
  class ConcurrentAnalyzer
    include Callable

    attr_accessor :dest_dir

    def initialize(root_dir:)
      self.dest_dir = root_dir

      unless Dir.exist?(self.dest_dir)
        FileUtils.mkdir_p(self.dest_dir)
      end
    end

    def command
      "lighthouse-batch -f #{root_dir}/sitemap.txt -o #{dest_dir}"
    end

    def call
      system(command)
      exit_code = $?.exitstatus
      raise "exit #{exit_code}" unless exit_code == 0
    end
  end
end
