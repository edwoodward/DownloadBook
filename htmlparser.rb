require 'nokogiri'

class HTMLParser < Nokogiri::XML::SAX::Document

  def initialize
    @resources = []
  end
  
  def start_element name, attributes = []
    if name == "img"
      for name, value in attributes
        if name == "src"
          if value.include? "/resources/"
            #add value to array
            @resources.push(value)
          end
        end
      end
    end
  end

  def get_resources
    return @resources
  end
  #include Nokogiri::XML::SAX
end
