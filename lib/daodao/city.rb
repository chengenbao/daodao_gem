module DaoDao
  class City
    attr_accessor :name, :geo, :tag
    GEO_SEARCH_URL = 'http://www.daodao.com/TypeAheadJson?action=GEO'
    CITY_SEARCH_URL = 'http://www.daodao.com/HACSearch'

    class << self
      ##
      # retrive daodao geo number from www.daodao.com
      #
      # city_name - name of the city you want to get geo
      #
      # return  the geo number of the city 
      def get_geo(city_name)
        raise ArgumentError.new('city name can not be empty') if city_name == nil or city_name.empty?
        fields = {}
        fields['query'] = city_name
        data = HttpRequester.get GEO_SEARCH_URL, fields

        data = data.gsub 'while(1);', ''
        array = JSON.parse data
        geo = ''
        array.each do |city|
          if city['name'].index city_name
            geo = city["value"]
          end
        end

        geo
      end
    end

    ##
    # retrive hotels from www.daodao.com, norrmaly you can get 15 items each time
    #
    # RuntiemError will be raised if the name property if empty
    #
    # return 15 or lesss hotels, each have a name and url, if there if no more nil will be returned
    def hotels
      raise RuntimeError.new('city name can not be empty') if name == nil or name.empty?

      if geo == nil || geo.empty?
        geo = City.get_geo(name)
      end

      page = ''
      if @next_page_url == nil # the first time crawl
        field = {}
        field['geo'] = geo

        page = HttpRequester.get CITY_SEARCH_URL, field
      elsif @next_page_url == 'END'
        return nil
      else
        page = HttpRequester.get @next_page_url, nil
      end

      parse_next_page_url page
      hotels = parse_hotels page
    end

    ##
    # reset the cursor of the city hotels search
    def rewind
      @next_page_url = nil
    end

    private 
    def parse_hotels(p)
      reg = /<a target="_blank" class="property_title" href="(.+\.html)" onclick="setPID\(\d+\);" title="[^<>]+">\s+<span itemprop="name">([^<>]+)<\/span>\s+<\/a>/
      match = p.scan reg

      hotels = {}

      match.each do |item|
        url = "http://www.daodao.com#{item[0]}"
        name = item[1]
        hotels[name] = url
      end

      return hotels
    end

    def parse_next_page_url(p)
      reg= /<a href="(.+\.html)" class="next sprite-arrow-right-green ml6 js_HACpager">[^<>]+<\/a>/
      match = p.scan reg

      if match && match.length > 0  
        @next_page_url = "http://www.daodao.com#{match[0][0]}"
      else
        @next_page_url = 'END'
      end
    end
  end
end
