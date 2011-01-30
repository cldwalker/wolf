require 'wolfram'
require 'hirb'

module Wolf
  ALIASES = {}
  OPTIONS = { :o => :open, :m => :menu, :x => :xml, :v => :verbose, :h => :help }
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
  rescue ArgumentError
    abort "Wolf Error: Wrong number of arguments"
  end

  def browser_opens(uri)
    system('open', uri)
  end

  def parse_options(argv)
    options, fetch_options = {}, {}
    while argv[0] =~ /^-/
      arg = argv.shift
      if (opt = arg[/^--?(\w+)/, 1]) && (OPTIONS.key?(opt.to_sym) || OPTIONS.value?(opt.to_sym))
        options[OPTIONS[opt.to_sym] || opt.to_sym] = true
      elsif arg[/^--(\w+)=(\S+)/]
        fetch_options[$1.to_sym] = $2
      end
    end
    [options, fetch_options]
  end

  def devour(argv=ARGV)
    options, fetch_options = parse_options(argv)
    if argv.empty? || options[:help]
      return puts('wolf [-o|--open] [-m|--menu] [-x|--xml] [-v|--verbose] [-h|--help] QUERY')
    end
    load_rc '~/.wolfrc'
    query = build_query(argv)
    _devour(query, options, fetch_options)
  end

  def _devour(query, options, fetch_options)
    if options[:open]
      browser_opens Wolfram.query(query,
        :query_uri => "http://www.wolframalpha.com/input/").uri(:i => query)
    elsif options[:xml]
      puts Wolfram.fetch(query, fetch_options).xml
    else
      result = Wolfram.fetch(query, fetch_options)
      render_result result, options

      if options[:menu]
        choices = []
        result.pods.select {|e| e.states.size > 0 }.each {|e|
          choices += e.states.map {|s| [e.title, s.name] } }
        puts "\n** LINKS **"
        choice = Hirb::Menu.render(choices, :change_fields => ['Section', 'Choice'],
          :prompt =>"Choose one link to requery: ", :description => false,
          :directions => false)[0]
        if choice && (pod = result[choice[0]]) && state = pod.states.find {|e| e.name == choice[1] }
          render_result(state.refetch, options)
        else
          abort "Wolf Error: Unable to find this link to requery it"
        end
      end
    end
  end

  def render_result(result, options)
    puts render(result)
    puts "\nURI requested: #{result.uri}\n" if options[:verbose]
    puts "Found #{result.pods.size} pods" if options[:verbose]
  end

  def render(result)
    Hirb.enable
    body = ''
    pods = result.pods.reject {|e| e.title == 'Input interpretation' || e.plaintext == '' }
    # multiple 1-row tables i.e. math results
    if pods.all? {|e| !e.plaintext.include?('|') }
      body << render_table(pods.map {|e| [e.title, e.plaintext] })
    # one one-row table i.e. word results
    elsif pods.size == 1 && pod_rows(pods[0]).size == 1
      body << pods[0].title.capitalize << "\n"
      body << render_table(pod_rows(pods[0])[0])
    else
      pods.each do |pod|
        body << pod.title.capitalize << "\n"

        # Handle multiple tables divided by graphs i.e. when comparing stocks
        if pod.plaintext.include?("\n\n") && pod.states.empty?
          pod.plaintext.split(/\n{2,}/).each {|text|
            body << render_pod_rows(text_rows(text), text)
          }
        else
          body << render_pod_rows(pod_rows(pod), pod.plaintext)
        end
      end
    end
    body
  end

  def render_pod_rows(rows, text)
    # delete comments
    rows.delete_if {|e| e.size == 1 } if rows.size > 1
    headers = text[/^\s*\|/] ? rows.shift : false
    render_table(rows, headers) << "\n\n"
  end

  def render_table(rows, headers=false)
    Hirb::Helpers::AutoTable.render(rows, :description => false, :headers => headers)
  end

  def pod_rows(pod)
    text_rows pod.plaintext
  end

  def text_rows(text)
    text.split(/\n+/).map {|e| e.split(/\s+\|\s+/) }.delete_if {|e| e.size == 0 }
  end
end
