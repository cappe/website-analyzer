class LighthouseReporter
  class LighthouseRunner
    include Callable

    attr_accessor :sitemap_path,
                  :dest_dir

    def initialize(sitemap_path:, dest_dir:)
      self.sitemap_path = sitemap_path
      self.dest_dir = "#{dest_dir}/lighthouse"

      unless Dir.exist?(self.dest_dir)
        FileUtils.mkdir_p(self.dest_dir)
      end
    end

    def command
      "lighthouse-batch -v -f #{sitemap_path} -o #{dest_dir}"
    end

    def call
      system(command)

      exit_code = $?.exitstatus
      raise "exit #{exit_code}" unless exit_code == 0

      self.dest_dir
    end
  end
end
