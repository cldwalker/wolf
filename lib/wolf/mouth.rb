module Wolf
  module Mouth
    extend self

    def eat(argv, options, fetch_options)
      load_rc '~/.wolfrc'
      options[:load] ? eat_at_home(argv, options) :
        eat_out(build_query(argv), options, fetch_options)
    end

    def eat_at_home(files, options)
      Hirb.enable
      files.each {|file|
        Mouth.swallow Wolfram::Result.new(File.read(@file = file)), options
      }
    rescue Errno::ENOENT
      abort "Wolf Error: File '#{@file}' does not exist"
    end

    def load_rc(file)
      load file if File.exists?(File.expand_path(file))
    rescue StandardError, SyntaxError, LoadError => e
      warn "Wolf Error while loading #{file}:\n"+
        "#{e.class}: #{e.message}\n    #{e.backtrace.join("\n    ")}"
    end

    def build_query(args)
      cmd = args.shift
      cmd_alias = ALIASES[cmd]  || ALIASES[cmd.to_sym]
      if cmd_alias.to_s.include?('%s')
        cmd_alias % args
      else
        cmd = cmd_alias || cmd
        ([cmd] + args).join(' ')
      end
    rescue ArgumentError
      abort "Wolf Error: Wrong number of arguments"
    end

    def eat_out(query, options, fetch_options)
      if options[:open]
        open Wolfram.query(query,
          :query_uri => "http://www.wolframalpha.com/input/").uri(:i => query)
      elsif options[:xml]
        puts Wolfram.fetch(query, fetch_options).xml
      else
        Hirb.enable
        result = Wolfram.fetch(query, fetch_options)
        swallow result, options
        menu(result) if options[:menu]
      end
    end

    def menu(result)
      choices = []
      result.pods.select {|e| e.states.size > 0 }.each {|e|
        choices += e.states.map {|s| [e.title, s.name] } }
      puts "\n** LINKS **"
      choice = Hirb::Menu.render(choices, :change_fields => ['Section', 'Choice'],
        :prompt =>"Choose one link to requery: ", :description => false,
        :directions => false)[0]
      if choice && (pod = result[choice[0]]) && state = pod.states.find {|e| e.name == choice[1] }
        swallow state.refetch, options
      else
        abort "Wolf Error: Unable to find this link to requery it"
      end
    end

    def swallow(result, options={})
      if result.success
        puts Stomach.digest(result, options)
      else
        warn "No results found"
      end
      puts "\nURI: #{result.uri}", "Fetched in #{result.timing}s",
        "Found #{result.pods.size} pods" if options[:verbose]
    end

    def open(uri)
      system('open', uri)
    end
  end
end
