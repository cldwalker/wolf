module Wolf
  module Stomach
    extend self

    def digest(result, options)
      body = ''
      pods = options[:all] ? result.pods :
        result.pods.reject {|e| e.title == 'Input interpretation' || e.plaintext == '' }
      pods = pods.select {|e| e.title[/#{options[:title]}/i] } if options[:title]
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
            strip(pod.plaintext).split(/\n{2,}/).each {|text|
              body << render_pod_rows(text_rows(text), text, options)
            }
          else
            body << render_pod_rows(pod_rows(pod), strip(pod.plaintext), options)
          end
        end
      end
      body
    end

    def render_pod_rows(rows, text, options)
      # delete comments
      rows.delete_if {|e| e.size == 1 } if rows.size > 1 && !options[:all]
      headers = text[/^\s*\|/] ? rows.shift : false
      render_table(rows, headers) << "\n\n"
    end

    def render_table(rows, headers=false)
      Hirb::Helpers::AutoTable.render(rows, :description => false, :headers => headers)
    end

    def pod_rows(pod)
      text_rows strip(pod.plaintext)
    end

    def strip(text)
      text.sub(/\A(\s+\|){2,}/m, '').sub(/(\s+\|){2,}\s*\Z/, '').strip
    end

    def text_rows(text)
      text.split(/\n+/).map {|e| e.split(/\s*\|\s+/) }
    end
  end
end
