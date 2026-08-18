$LOAD_PATH.unshift(File.expand_path("lib", __dir__))

require_relative "config/application"

Rails.application.load_tasks

begin
  require "rake/extensiontask"
  Rake::ExtensionTask.new("dsp_analyzer") do |ext|
    ext.ext_dir = "ext/dsp_analyzer"
    ext.lib_dir = "lib" # Outputs compiled library binary here
  end

  task spec: :compile
  task test: :compile
rescue LoadError

end
