require 'rubyXL'
require 'rubyXL/convenience_methods'

class LighthouseReporter
  class WriteConcurrentSummaryReport
    include Callable

    attr_accessor :workbook,
                  :worksheet,
                  :root_dir

    HEADER_ROW = 0
    URL_COL = 0

    LCP_COL = 7
    ERROR_COL = 8

    OK_FONT_COLOR = '0C5100'
    OK_BG_COLOR = 'BDEDC4'
    SATISFACTORY_FONT_COLOR = '8A4504'
    SATISFACTORY_BG_COLOR = 'FFE88B'
    UNACCEPTABLE_FONT_COLOR = '880009'
    UNACCEPTABLE_BG_COLOR = 'FEB9C4'
    SATISFACTORY_THRESHOLD = 0.6
    OK_THRESHOLD = 0.9
    DEFAULT_COL_WIDTH = 16

    CLS_GOOD_THRESHOLD = 0.1
    CLS_SATISFACTORY_THRESHOLD = 0.15

    LCP_GOOD = 2.5
    LCP_NEEDS_IMPROVEMENT = 4

    def initialize(root_dir:)
      self.workbook = RubyXL::Workbook.new
      self.worksheet = workbook[0]
      self.root_dir = root_dir
    end

    def summary_json_path
      "#{self.root_dir}/summary.json"
    end

    def page_summary(page)
      JSON.parse(File.read("#{self.root_dir}/#{page}"))
    end

    def rows
      @rows ||= JSON.parse(File.read(self.summary_json_path))
    end

    def write_header
      worksheet.add_cell(HEADER_ROW, URL_COL, 'Page')
      worksheet.add_cell(HEADER_ROW, 1, 'Performance')
      worksheet.add_cell(HEADER_ROW, 2, 'Accessibility')
      worksheet.add_cell(HEADER_ROW, 3, 'Best Practices')
      worksheet.add_cell(HEADER_ROW, 4, 'SEO')
      worksheet.add_cell(HEADER_ROW, 5, 'PWA')
      worksheet.add_cell(HEADER_ROW, 6, 'CLS')
      worksheet.add_cell(HEADER_ROW, LCP_COL, 'LCP')

      worksheet.change_column_width(1, DEFAULT_COL_WIDTH)
      worksheet.change_column_width(2, DEFAULT_COL_WIDTH)
      worksheet.change_column_width(3, DEFAULT_COL_WIDTH)
      worksheet.change_column_width(4, DEFAULT_COL_WIDTH)
      worksheet.change_column_width(5, DEFAULT_COL_WIDTH)
      worksheet.change_column_width(6, DEFAULT_COL_WIDTH)
      worksheet.change_column_width(LCP_COL, DEFAULT_COL_WIDTH)

      worksheet[HEADER_ROW][0].change_font_bold(true)
      worksheet[HEADER_ROW][1].change_font_bold(true)
      worksheet[HEADER_ROW][2].change_font_bold(true)
      worksheet[HEADER_ROW][3].change_font_bold(true)
      worksheet[HEADER_ROW][4].change_font_bold(true)
      worksheet[HEADER_ROW][5].change_font_bold(true)
      worksheet[HEADER_ROW][6].change_font_bold(true)
      worksheet[HEADER_ROW][7].change_font_bold(true)
    end

    # Good - nothing to do here = CLS of 0.1 or less.
    # OK, but consider improvement = CLS between 0.1 and 0.15.
    # Longer than recommended = CLS between 0.15 and 0.25.
    # Much longer than recommended = CLS of 0.25 or higher .
    def get_cls_bg_color(v)
      return OK_BG_COLOR if v <= CLS_GOOD_THRESHOLD
      return SATISFACTORY_BG_COLOR if v <= CLS_SATISFACTORY_THRESHOLD
      UNACCEPTABLE_BG_COLOR
    end

    def get_lcp_bg_color(v)
      return OK_BG_COLOR if v <= LCP_GOOD
      return SATISFACTORY_BG_COLOR if v <= LCP_NEEDS_IMPROVEMENT
      UNACCEPTABLE_BG_COLOR
    end

    def get_lcp_font_color(v)
      return OK_FONT_COLOR if v <= LCP_GOOD
      return SATISFACTORY_FONT_COLOR if v <= LCP_NEEDS_IMPROVEMENT
      UNACCEPTABLE_FONT_COLOR
    end

    def get_cls_font_color(v)
      return OK_FONT_COLOR if v <= CLS_GOOD_THRESHOLD
      return SATISFACTORY_FONT_COLOR if v <= CLS_SATISFACTORY_THRESHOLD
      UNACCEPTABLE_FONT_COLOR
    end

    def get_bg_color(v)
      return UNACCEPTABLE_BG_COLOR unless v
      return UNACCEPTABLE_BG_COLOR if v < SATISFACTORY_THRESHOLD
      return SATISFACTORY_BG_COLOR if v < OK_THRESHOLD
      OK_BG_COLOR
    end

    def get_font_color(v)
      return UNACCEPTABLE_BG_COLOR unless v
      return UNACCEPTABLE_FONT_COLOR if v < SATISFACTORY_THRESHOLD
      return SATISFACTORY_FONT_COLOR if v < OK_THRESHOLD
      OK_FONT_COLOR
    end

    def get_metrics(page)
      metrics = page['detail']
      page_summary = page_summary(page['file'])
      cls = page_summary['audits']['cumulative-layout-shift']['displayValue'].to_f

      {
        performance: metrics['performance'].to_f,
        accessibility: metrics['accessibility'].to_f,
        best_practices: metrics['best-practices'].to_f,
        seo: metrics['seo'].to_f,
        pwa: metrics['pwa'].to_f,
        cls: cls.to_f
      }
    end

    def write_rows
      min_col_widths = {}

      self.rows.each_with_index do |page, idx|
        row = idx + 1
        page_url = page['url'] || page['URL'] # concurrent has url, parallel has URL

        worksheet.add_cell(row, URL_COL, page_url)

        begin
          metrics = get_metrics(page)
          performance = metrics[:performance]
          accessibility = metrics[:accessibility]
          best_practices = metrics[:best_practices]
          seo = metrics[:seo]
          pwa = metrics[:pwa]
          cls = metrics[:cls]
          lcp = metrics[:lcp] rescue nil
        rescue Exception => e
          puts "==================".red
          puts "error: #{e}".red
          puts "url: #{page_url}".red

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

        worksheet.add_cell(row, 6, cls)
        worksheet[row][6].change_fill(get_cls_bg_color(cls))
        worksheet[row][6].change_font_color(get_cls_font_color(cls))

        worksheet.add_cell(row, LCP_COL, lcp)
        worksheet[row][LCP_COL].change_fill(get_lcp_bg_color(lcp))
        worksheet[row][LCP_COL].change_font_color(get_lcp_font_color(lcp))

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
      workbook.write("#{self.root_dir}/concurrent_summary_#{now}.xlsx")
    end

    def call
      write_header
      write_rows
      export
    end
  end
end