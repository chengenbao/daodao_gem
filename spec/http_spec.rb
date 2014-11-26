require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe 'HttpRequester' do
  it 'get www.daodao.com with no parameters' do
    page = DaoDao::HttpRequester.get 'http://www.baidu.com', nil
    expect(page).to include('baidu')
  end

  it 'search www.baidu.com with query' do
    field = {}
    field['wd'] = 'hadoop'

    page = DaoDao::HttpRequester.get 'http://www.baidu.com/s', field
    expect(page).to include('Welcome to Apache')
  end
end
