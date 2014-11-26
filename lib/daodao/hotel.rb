module DaoDao
  class Hotel
    HOTEL_SEARCH_URL = 'http://www.daodao.com/DaoDaoCheckRatesAjax?action=getSingleHotelMeta'
    attr_accessor :id, :name, :url
    attr_reader :rank, :home_page, :rooms

    class << self
      ##
      # retrieve all hotel at www.daodao.com, one page each time
      def all
      end
    end

    ##
    # retrive hotel info from www.daodao.com
    # either id or url must be specified
    #
    #  return a Hash contails the city info
    def info
      if @home_page == nil && @url != nil
        @home_page = HttpRequester.get url, nil
      elsif @id != nil 
        get_by_id
      end

      parse_name if @name == nil
      parse_rank if @rank == nil
      parse_rooms if @rooms == nil

      detail_info = {}
      detail_info[:name] = name
      detail_info[:rank] = rank
      detail_info[:rooms] = rooms

      detail_info
    end

    private 
    ##
    # retrieve home page from www.daodao.com
    #
    #  set the home_page property
    def get_by_id
      id_url = "http://www.daodao.com/#{id}"

      begin
        page = HttpRequester.get id_url, nil
        # redirect
        reg = /The document has moved <A HREF="([^<>]+)">here<\/A>/
        if match && match.length > 0
          @url = match[0][0]
        end
        @home_page = HttpRequester.get @url, nil
      rescue 
        raise RuntimeError.new 'Time out'
      end
    end

    ##
    # parse the home page and retrive the name of the hotel
    #
    # set the name property
    def parse_name
      namereg = /<span itemprop="name">([^<>]+)<\/span>/
      match = @home_page.scan namereg

      if match && match.length > 0
        @name = match[0][0]
      end
    end

    ##
    # parse the home page and retrive the rank info
    #
    # set the rank_info property
    def parse_rank
      reg = /all_single_meta_reqs = JSON.decode\('([^;]+)'\);/
      match = home_page.scan reg
      all_single_meta_reqs = match[0][ 0]

      all_single_meta_reqs = JSON.parse(all_single_meta_reqs)
      hotel_id = ''
      @rank = []

      all_single_meta_reqs.each do |single_mata_req|
        data = single_mata_req
        @id = data['hotel_id']
        @rank << data['svc_ops']['locToHACProviders'].values[0]
      end
    end

    def parse_rooms
      reg = /all_single_meta_reqs = JSON.decode\('([^;]+)'\);/
      match = home_page.scan reg
      tmp = match[0][ 0]

      all_single_meta_reqs = []
      tmp = tmp[1, tmp.length - 2]
      bindex = 0
      while eindex = tmp.index('{"hotel_id', bindex + 1)
        item = tmp[bindex, eindex - bindex - 1]
        all_single_meta_reqs << item
        bindex = eindex
      end

      if bindex < tmp.length
        all_single_meta_reqs << tmp[bindex, tmp.length - bindex]
      end
      @rooms = []
      all_single_meta_reqs.each do |single_mata_req|
        field = {}
        field['single_hotel_meta_req'] = single_mata_req

        json = HttpRequester.get HOTEL_SEARCH_URL, field
        json = json.gsub 'while(1);', ''
        @rooms << JSON.parse(json)
      end
    end
  end
end
