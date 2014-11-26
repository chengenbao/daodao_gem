require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe DaoDao::City do
  it 'get geo for beijing' do
    geo = DaoDao::City.get_geo '北京市'
    
    expect(geo).to eq('294212')
  end

  it 'get city hotels' do
    city = DaoDao::City.new
    city.name = '北京市'

    expect(city.hotels.length).to eq(15)
  end

  it 'get second page of hotels' do
    city = DaoDao::City.new
    city.name = '北京市'
    city.hotels

    hotels = []
    city.hotels.each do |k, v|
      puts k
      hotels << k
    end

    expect(hotels.length).to eq(15)
  end
end
