require 'wolfram'
require 'hirb'

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
      puts render(Wolfram.fetch(query))
    end
  rescue ArgumentError
    warn "Wolf Error: Wrong number of arguments"
  end

  def render(result)
    # result.inspect
    Hirb.enable
    body = ''
    pods = result.pods.reject {|e| e.title == 'Input interpretation' || e.plaintext == '' }
    # multiple 1-row tables i.e. math results
    if pods.all? {|e| !e.plaintext.include?('|') }
      rows  = pods.map {|e| [e.title, e.plaintext] }
      body << Hirb::Helpers::AutoTable.render(rows, :description => false, :headers => false) << "\n\n"
    # one one-row table i.e. word results
    elsif pods.size == 1 && pod_rows(pods[0]).size == 1
      rows = pod_rows(pods[0])[0]
      body << pods[0].title.capitalize << "\n"
      body << Hirb::Helpers::AutoTable.render(rows, :description => false, :headers => false) << "\n\n"
    else
      pods.each do |pod|
        body << pod.title.capitalize << "\n"
        rows = pod_rows pod
        rows.delete_if {|e| e.size == 1 } if rows.size > 1
        headers = pod.plaintext[/^\s*\|/] ? rows.shift : false
        body << Hirb::Helpers::AutoTable.render(rows, :description => false, :headers => headers) << "\n\n"
      end
    end
    body
  end

  def pod_rows(pod)
    pod.plaintext.split("\n").map {|e| e.split(/\s+\|\s+/) }.delete_if {|e| e.size == 0 }
  end
end
