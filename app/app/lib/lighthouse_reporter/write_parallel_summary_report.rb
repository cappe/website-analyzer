require 'rubyXL'
require 'rubyXL/convenience_methods'

class LighthouseReporter
  class WriteParallelSummaryReport < WriteConcurrentSummaryReport
    def get_metrics(page)
      metrics = page['audits']

      {
        performance: metrics['performance']['score'].to_f,
        accessibility: metrics['accessibility']['score'].to_f,
        best_practices: metrics['best-practices']['score'].to_f,
        seo: metrics['seo']['score'].to_f,
        pwa: metrics['pwa']['score'].to_f,
        cls: metrics['cumulative-layout-shift']['score'].to_f
      }
    end

    def export
      now = DateTime.now.strftime('%d_%m_%Y_klo_%H:%M')
      workbook.write("#{self.root_dir}/parallel_summary_#{now}.xlsx")
    end

    def call
      write_header
      write_rows
      export
    end
  end
end
