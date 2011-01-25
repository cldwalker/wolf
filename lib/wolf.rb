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
    cmd = ALIASES[cmd]  || ALIASES[cmd.to_sym] || cmd
    ([cmd] + args).join(' ')
  end

  def devour(argv=ARGV)
    load_rc '~/.wolfrc'
    query = build_query(argv)
    puts Wolfram.fetch(query).inspect
  end
end
