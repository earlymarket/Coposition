class ReadmeInterpreter

  attr_reader :text

  def initialize(filename)
    binding.pry
    @text = "File.read(filename)"
  end



end