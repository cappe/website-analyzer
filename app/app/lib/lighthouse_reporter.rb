class LighthouseReporter
  include Callable

  attr_accessor :runner

  def initialize(runner:)
    self.runner = runner
  end

  def call
    self.runner.call
  end
end
