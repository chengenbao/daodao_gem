require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe DaoDao::Hotel do
  it 'get hotel info' do
    city = DaoDao::Hotel.new

    city.url = 'http://www.daodao.com/Hotel_Review-g294212-d3198755-Reviews-The_HuLu_Hotel-Beijing.html'

    puts city.info
  end
end
