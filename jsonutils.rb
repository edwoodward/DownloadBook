require "rubygems"
require "json"
require "net/http"
require "uri"
require 'nokogiri' 
require_relative 'htmlparser'
require 'fileutils'
require "open-uri"

class JsonUtils

  def initialize()
    @json = ""
  end
  
  def load_book_json(book_id)
    url = "https://archive.cnx.org/contents/" + book_id + ".json"
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    if response.code == "200"
      @json = JSON.parse(response.body)
    else
      response = Net::HTTP.get_response(URI.parse(response.header['location']))
      @json = JSON.parse(response.body)
    end
  end

  def get_tree
    return @json["tree"]
  end

  def load_page(page_id)
    url = "https://archive.cnx.org/contents/" + page_id + ".json"
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    if response.code == "200"
      page_json = JSON.parse(response.body)
    else
      begin
        response = Net::HTTP.get_response(URI.parse(response.header['location']))
        page_json = JSON.parse(response.body)
      rescue => e
        puts "Error: " + page_id
      end
    end

    if page_json == nil
      return ""
    else
      return page_json['content']
    end
    
  end

  def get_book_name
    tree = get_tree
    return tree["title"]
  end

  def get_title(html)
    page = Nokogiri::HTML.parse(html)
    return page.title
  end

  def get_resources(page_html)
    doc = HTMLParser.new
    parser = Nokogiri::HTML::SAX::Parser.new(doc)
    parser.parse(page_html)
    return doc.get_resources
  end

  def fix_resource_urls(page_html)
    return page_html.gsub("/resources", "resources")
  end

  def save_resource(resource_url, book_name)
    strArray = resource_url.split("/")
    path = "/" + strArray[1] + "/" + strArray[2]
    FileUtils.mkdir_p book_name + "/" + path unless File.exists?(book_name + "/" + path)
    open(URI.encode("https://archive.cnx.org" + resource_url)) do |image|
      File.open(book_name + resource_url, "wb") do |file|
        file.write(image.read)
      end
    end
  end

  def remove_version(page_id)
    #removes version (@X.X) from page id
    #:param page_id: page id to modify
    #:return: page id minus version
    index = page_id.index('@')
    return page_id[0..index-1]
  end
end

#tests for functions
#ju = JsonUtils.new()
#ju.load_book_json '8d50a0af-948b-4204-a71d-4826cba765b8'
#puts ju.get_book_name
#returned_html = ju.load_page '2e737be8-ea65-48c3-aa0a-9f35b4c6a966','2e737be8-ea65-48c3-aa0a-9f35b4c6a966:cb6bb591-e7aa-5fd5-bbb8-d12a0e38d00f'
#puts returned_html
#puts ju.get_resources returned_html
#puts ju.save_resource '/resources/5eef3633e02cbfd8c4f3eac5b47c4525025bc98f/OSC_Astro_09_02_ Apollo15.jpg', 'Astrology'
#puts ju.remove_version 'db36053c-5281-42f4-90ec-afcc21ab28c3@15'