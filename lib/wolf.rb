require 'wolfram'

module Wolf
  ALIASES = {}
  extend self

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
  end

  def browser_opens(uri)
    system('open', uri)
  end

  def devour(argv=ARGV)
    return puts('wolf [-o|--open] QUERY') if argv.empty?
    load_rc '~/.wolfrc'
    open_option = argv.delete('-o') || argv.delete('--open')
    query = build_query(argv)
    if open_option
      browser_opens Wolfram.query(query,
        :query_uri => "http://www.wolframalpha.com/input/").uri(:i => query)
    else
      puts Wolfram.fetch(query).inspect
    end
  rescue ArgumentError
    warn "Wolf Error: Wrong number of arguments"
  end
end
