require 'rubyXL'
require 'rubyXL/convenience_methods'

class LighthouseReporter
  class GenerateSummary
    include Callable

    attr_accessor :workbook,
                  :worksheet,
                  :source_path,
                  :dest_path

    HEADER_ROW = 0
    URL_COL = 0
    OK_FONT_COLOR = '0C5100'
    OK_BG_COLOR = 'BDEDC4'
    SATISFACTORY_FONT_COLOR = '8A4504'
    SATISFACTORY_BG_COLOR = 'FFE88B'
    UNACCEPTABLE_FONT_COLOR = '880009'
    UNACCEPTABLE_BG_COLOR = 'FEB9C4'
    SATISFACTORY_THRESHOLD = 0.6
    OK_THRESHOLD = 0.9
    DEFAULT_COL_WIDTH = 16

    def initialize(source_path:, dest_path:)
      self.workbook = RubyXL::Workbook.new
      self.worksheet = workbook[0]
      self.source_path = source_path
      self.dest_path = dest_path
    end

    def rows
      @rows ||= JSON.parse(File.read(self.source_path))
    end

    def write_header
      worksheet.add_cell(HEADER_ROW, URL_COL, 'Page')
      worksheet.add_cell(HEADER_ROW, 1, 'Performance')
      worksheet.add_cell(HEADER_ROW, 2, 'Accessibility')
      worksheet.add_cell(HEADER_ROW, 3, 'Best Practices')
      worksheet.add_cell(HEADER_ROW, 4, 'SEO')
      worksheet.add_cell(HEADER_ROW, 5, 'PWA')

      worksheet.change_column_width(1, DEFAULT_COL_WIDTH)
      worksheet.change_column_width(2, DEFAULT_COL_WIDTH)
      worksheet.change_column_width(3, DEFAULT_COL_WIDTH)
      worksheet.change_column_width(4, DEFAULT_COL_WIDTH)
      worksheet.change_column_width(5, DEFAULT_COL_WIDTH)

      worksheet[HEADER_ROW][0].change_font_bold(true)
      worksheet[HEADER_ROW][1].change_font_bold(true)
      worksheet[HEADER_ROW][2].change_font_bold(true)
      worksheet[HEADER_ROW][3].change_font_bold(true)
      worksheet[HEADER_ROW][4].change_font_bold(true)
      worksheet[HEADER_ROW][5].change_font_bold(true)
    end

    def get_bg_color(v)
      return UNACCEPTABLE_BG_COLOR if v < SATISFACTORY_THRESHOLD
      return SATISFACTORY_BG_COLOR if v < OK_THRESHOLD
      OK_BG_COLOR
    end

    def get_font_color(v)
      return UNACCEPTABLE_FONT_COLOR if v < SATISFACTORY_THRESHOLD
      return SATISFACTORY_FONT_COLOR if v < OK_THRESHOLD
      OK_FONT_COLOR
    end

    def write_rows
      min_col_widths = {}

      self.rows.each_with_index do |page, idx|
        row = idx + 1

        worksheet.add_cell(row, URL_COL, page['url'])

        begin
          detail = page['detail']
          performance = detail['performance']
          accessibility = detail['accessibility']
          best_practices = detail['best-practices']
          seo = detail['seo']
          pwa = detail['pwa']
        rescue
          puts "error: #{page['url']}".red

          worksheet.add_cell(row, 6, 'error')

          next

          # error: https://bonusetu.com/kasinobonuksien-kierratysehdot/
          # error: https://bonusetu.com/rahapelimarkkinoiden-vapautuminen-ruotsissa-2019/
          # error: https://bonusetu.com/em2020-vip-liput/
          # error: https://bonusetu.com/mobiilikasinot/
          # error: https://bonusetu.com/arvostelut/pronto-casino/
          # error: https://bonusetu.com/arvostelut/n1-casino/
          # error: https://bonusetu.com/arvostelut/rocket-casino/
          # error: https://bonusetu.com/arvostelut/nopeampi/
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
      workbook.write("#{self.dest_path}/summary.xlsx")
    end

    def call
      write_header
      write_rows
      export
    end
  end
end