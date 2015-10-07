require 'endo'
require 'thor'

module Endo
  class CLI < Thor
    default_command :exec

    desc "exec usage", "exec desc"
    def exec(endo_file=nil)
      executor = Endo::Core.new
      if endo_file.nil?
        Dir.glob('endo/*.endo').each do |f|
          executor.instance_eval File.read(f)
        end
      else
        executor.instance_eval File.read(endo_file)
      end
    end

    desc "version", "Print version"
    def version
      puts "endo version #{Endo::VERSION}"
    end
  end
end