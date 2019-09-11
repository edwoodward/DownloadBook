require_relative 'jsonutils'
require 'fileutils'

class CLI

  def initialize()
    @j_utils = nil
    @book_title = ""
  end

  def run_cli
    puts 'Please enter book UUID: '
    book_id = gets.strip
    @j_utils = JsonUtils.new
    @j_utils.load_book_json book_id
    toc_json = @j_utils.get_tree
    @book_title = toc_json["title"]
    FileUtils.mkdir_p @book_title
    toc_html = File.open(@book_title + "/" + "toc.html", 'w')
    toc_html.write("<html>\n")
    toc_html.write("<body>\n")
    
    for section in toc_json["contents"]
      toc_html.write("<li>")
      write_toc_element(book_id, toc_html, section)
      toc_html.write("</li>")
    end
    toc_html.write("</ul>")
    # Finish writing toc
    toc_html.write("</body>\n")
    toc_html.write("</html>\n")
    toc_html.close()
  end

  def write_toc_element(book_id, html, json_tree)
    # If no contents, there's no actual html associated w/ this page, so no link is required
    if json_tree["contents"] != nil
      html.write(json_tree["title"])
      html.write("<ul>\n")
      contents = json_tree["contents"]
      # Write each member of this tree
      for elem in contents
          html.write("<li>\n")
          write_toc_element(book_id, html, elem)
          html.write("</li>\n")
      end
      html.write("</ul>\n")
    else
      # Otherwise, it's an individual page, link to it directly
      setup_page(book_id, json_tree["id"], json_tree["title"])
      html.write("<a href=\"" + json_tree["id"] + ".html" + "\">" + json_tree["title"].encode('utf-8') + "</a>\n")
    end
  end

  def setup_page(book_id, page_id, title)
    puts "\n================================"
    puts "setting up page: " + page_id
    page_html = @j_utils.load_page(@j_utils.remove_version(page_id))
    if page_html != ""
      page_html = page_html.encode('utf-8')
      resources = @j_utils.get_resources(page_html)
      page_html = @j_utils.fix_resource_urls(page_html)

      f = open(@book_title + "/" + page_id + ".html", "w")
      f.write(page_html)
      f.close()

      for resource in resources
        puts "retreiving resource: " + resource
        @j_utils.save_resource(resource, @book_title)
      end
    end
  end
end

#CLI
cli = CLI.new
cli.run_cli
