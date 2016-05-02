require 'endo'
require 'thor'

module Endo
  class CLI < Thor
    default_command :exec

    desc "exec usage", "exec desc"
    def exec(endo_file=nil)
      if endo_file.nil?
        Dir.glob('endo/*.rb').each do |f|
          exec_proc(f)
        end
      else
        exec_proc(endo_file)
      end
    end

    desc "version", "Print version"
    def version
      puts "endo version #{Endo::VERSION}"
    end

    private
    def exec_proc(file_path)
      executor = Endo::Core.new
      executor.instance_eval File.read(file_path)
    end
  end
end
