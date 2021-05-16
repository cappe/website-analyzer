class LighthouseReporter
  class ParallelAnalyzer
    include Callable

    attr_accessor :root_dir,
                  :dest_dir,
                  :workers

    def initialize(root_dir:, workers:)
      self.root_dir = root_dir
      self.dest_dir = root_dir
      self.workers = workers

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
      # params = {
      #   sitemap: self.sitemap,
      #   dest_dir: self.dest_dir,
      #   output: 'summary.json',
      # }.map { |key, val| "#{key.to_s.camelcase(:lower)}=#{val}" }
      #  .join(' ')
      #
      # command = "node #{Rails.root}/lighthouse-parallel-runner.js #{params}"
      # puts "Running system command #{command}".blue
      # command

      params = [
        "--path #{dest_dir}",
        "--file-name summary.json",
        "--output-format jsObject",
        "--number #{workers}",
        "--log-mode",
        "#{root_dir}/sitemap.json",
        "--audits-config #{Rails.root}/config/lighthouse_runner_config.json"
      ].join(" ")

      "lighthouse-batch-parallel #{params}"
    end

    def call
      system(command)
      exit_code = $?.exitstatus
      raise "exit #{exit_code}" unless exit_code == 0
    end
  end
end
