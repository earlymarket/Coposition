class ReadmeInterpreter

  attr_reader :text

  def initialize(filename)
    @text = File.read(filename)
  end

  def create_api_page
    res = split_relevant_lines.map do |line| 
      line = insert_line_breaks line 
      line = insert_header_tags line
      line = insert_code_tags line
    end
  end

  private

    def split_relevant_lines
      /## Example API usage(?<res>.+)--------$/m =~ @text
      res.split("\n\n").map { |line| line unless line.blank? }.compact
    end

    def insert_line_breaks(target)
      target = target.gsub("\n", "<br>") unless target.starts_with? "#"
      target
    end

    def insert_header_tags(target)
      if target.starts_with? "#"
        target = target.gsub("### ", "<h3>") + "</h3>" unless target.starts_with? "<h"
        target = target.gsub("## ", "<h2>") + "</h2>" unless target.starts_with? "<h"
        target = target.gsub("# ", "<h1>") + "</h1>" unless target.starts_with? "<h"
      end
      target
    end

    def insert_code_tags(target)
      if target.include? "```"
        target = target.split("```")[1..-1].map { |line| "<code>" + line + "</code>" }.join
      end
      if target.include? "`"
        target = target.split("`")[1..-1].map { |line| "<code>" + line + "</code>" }.join
      end
      target
    end

end