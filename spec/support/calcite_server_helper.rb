# encoding: utf-8
module CalciteServerHelper

  def with_a_calcite_server_at(endpoint)
    unless (jar = ENV["TI_CALCITE_JAR"])
      fail "Missing path to Calcite JAR in TI_CALCITE_JAR environment variable"
    end

    pid = fork do
      exec("java -jar #{jar} #{endpoint}")
    end

    begin
      result = yield
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
      result
    end
  end
end

RSpec.configure do |c|
  c.include CalciteServerHelper
end
