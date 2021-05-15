require 'rubyXL'
require 'rubyXL/convenience_methods'

class LighthouseReporter
  class WriteParallelSummaryReport < WriteConcurrentSummaryReport
    def write_rows
      min_col_widths = {}

      self.rows.each_with_index do |page, idx|
        row = idx + 1

        worksheet.add_cell(row, URL_COL, page['URL'])

        begin
          metrics = page['audits']
          performance = metrics['performance']['score']
          accessibility = metrics['accessibility']['score']
          best_practices = metrics['best-practices']['score']
          seo = metrics['seo']['score']
          pwa = metrics['pwa']['score']

          # page_summary = page_summary_json(page['file'])
          # cls = page_summary['audits']['cumulative-layout-shift']['displayValue'].to_f
          # byebug
        rescue Exception => e
          puts "error: #{page['url']}".red

          worksheet.add_cell(row, ERROR_COL, 'error')

          next
        end

        worksheet.add_cell(row, 1, performance)
        worksheet[row][1].change_fill(get_bg_color(performance))
        worksheet[row][1].change_font_color(get_font_color(performance))

        worksheet.add_cell(row, 2, accessibility)
        worksheet[row][2].change_fill(get_bg_color(accessibility))
        worksheet[row][2].change_font_color(get_font_color(accessibility))

        worksheet.add_cell(row, 3, best_practices)
        worksheet[row][3].change_fill(get_bg_color(best_practices))
        worksheet[row][3].change_font_color(get_font_color(best_practices))

        worksheet.add_cell(row, 4, seo)
        worksheet[row][4].change_fill(get_bg_color(seo))
        worksheet[row][4].change_font_color(get_font_color(seo))

        worksheet.add_cell(row, 5, pwa)
        worksheet[row][5].change_fill(get_bg_color(pwa))
        worksheet[row][5].change_font_color(get_font_color(pwa))

        # worksheet.add_cell(row, 6, cls)
        # worksheet[row][6].change_fill(get_cls_bg_color(cls))
        # worksheet[row][6].change_font_color(get_cls_font_color(cls))

        # Auto-resize URL col
        url_cell_content = worksheet[row][URL_COL]&.value
        min_col_width = [(url_cell_content.size * 0.9).to_i, (min_col_widths[URL_COL]&.size || 0)].max
        min_col_widths[URL_COL] = min_col_width
        if worksheet.get_column_width(URL_COL) < min_col_width
          worksheet.change_column_width(URL_COL, min_col_width)
        end
      end
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
