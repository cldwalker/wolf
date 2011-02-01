module Wolf
  module Mouth
    extend self

    def eat(query, options, fetch_options)
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
      puts "\nURI requested: #{result.uri}\n" if options[:verbose]
      puts "Found #{result.pods.size} pods" if options[:verbose]
    end

    def open(uri)
      system('open', uri)
    end
  end
end
