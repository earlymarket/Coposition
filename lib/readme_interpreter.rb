class ReadmeInterpreter

  attr_reader :text

  def initialize(filename)
    @text = File.read(filename)
  end

  def create_api_page
    renderer = Redcarpet::Render::HTML.new({ 
        hard_wrap: true,
        prettify: true
      })
    markdown = Redcarpet::Markdown.new(renderer, autolink: true)
    markdown.render(relevant_lines)
  end

  private

    def relevant_lines
      /## Example API usage(?<res>.+)--------$/m =~ @text
      res
    end
end