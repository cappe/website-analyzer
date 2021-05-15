class LighthouseReporter
  class ParallelAnalyzer
    include Callable

    attr_accessor :root_dir,
                  :dest_dir,
                  :sitemap

    def initialize(root_dir:, sitemap:)
      self.root_dir = root_dir
      self.dest_dir = "#{root_dir}/parallel_reports"
      self.sitemap = sitemap

      unless Dir.exist?(self.dest_dir)
        FileUtils.mkdir_p(self.dest_dir)
      end
    end

    # -a <path>   ||  --audits-config <path>    { Custom audits config }
    # -t <method> ||  --throttling <method>     { Throttling Method }
    # -p <path>   ||  --path <path>             { The location of output file }
    # -f <name>   ||  --file-name <name>        { The name of output file }
    # -o <format> ||  --output-format <format>  { The output format }
    # -n <number> ||  --number <number>         { Number of workers }
    # -l          ||  --log-mode                { Log progress of process }
    # -e          ||  --error-log-file          { Output error log file}
    def command
      params = [
        "--path #{dest_dir}",
        # "--audits-config #{root_dir}/config.json",
        "--file-name summary.json",
        "--output-format jsObject",
        "--number 10",
        "--log-mode",
        self.sitemap # The input file has to be the last one
      ].join(" ")

      "lighthouse-batch-parallel #{params}"
    end

    def call
      system(command)
      exit_code = $?.exitstatus

      raise "exit #{exit_code}" unless exit_code == 0

      self.dest_dir
    end
  end
end
