#!/usr/bin/env ruby

require 'socket'
require 'uri'
require 'timeout'

##################################################
#
# Filename: http_requester.rb
# http 请求类，通过HTTP GET或者POST方式获取网页
#
# Author: chengenbao
# Email: genbao.chen@gmail.com
#
##################################################

module DaoDao
  class HttpRequester
    GET = 'GET'
    POST = 'POST'
    TIMEOUT = 30


    class << self
      # 通过GET方式获取网页，
      # @url: 获取网页的地址
      # @field: 请求参数

      def get(url, field)
        url_group = split_url(url)
        if url_group == nil
          return nil
        end

        hostname = url_group[0]
        port = url_group[1]
        uri = url_group[2]

        header = build_header(HttpRequester::GET, uri, hostname, port, field)
        data = retrieve_data(hostname, port, header)

        return data
      end

      def build_header(method, uri, hostname, port, field)
        query = ''

        if field != nil
          i = 0
          field.each do |k, v| 
            if i > 0
              query << '&'
            end
            key = URI.escape(k)
            value=URI.escape(v)
            query << "#{key}=#{value}"
          end
        end

        if method == HttpRequester::GET && query.length > 0
          if uri.index('?') == nil
            uri << '?'
          else
            uri << '&'
          end

          uri << query
        end

        header = ''
        header << "#{method} #{uri} HTTP/1.1\r\n"
        header << "Accept: text/html, application/xhtml+xml, */*\r\n"
        header << "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko\r\n"

        header << "Host: #{hostname}"
        if port != 80
          header << ":#{port}"
        end

        header << "\r\n"
        header << "\r\n"

        return header
      end

      # 从url中取出对应的服务器名称，端口，以及相对资源地址
      # 返回一个长队为3的列表，按次序一次存放hostname，port，uri
      def split_url(url)
        result = []

        host_reg = /[a-z0-9]+\.[\w]+\.[a-z]+/
          match = host_reg.match url
        if match
          result << match[0]
        else
          return nil
        end

        pattern = result[0] #匹配主机名

        port_reg = /[a-z0-9]+\.[\w]+\.[a-z]+:(\d+)/
          match = port_reg.match url
        if match && match.length > 0
          port = match[0][0]
          pattern = port
          port = port[1, port.length]  
          port = Integer(port)
          result << port
        else
          result << 80
        end

        index = url.index pattern
        uri = url[index + pattern.length, url.length]
        uri = '/' if uri == nil or uri.empty?
        result << uri

        return result
      end

      def retrieve_data(hostname, port, header)
        client = TCPSocket.open hostname, port

        client.print header

        data = ''
        line = nil

        timeout(TIMEOUT) do
          line = client.gets
        end

        while line
          data << line

          if /^0\r\n$/.match line
            break
          end

          timeout(TIMEOUT) do
            line = client.gets
          end
        end

        client.close

        header, data = data.split("\r\n\r\n", 2)
        if header.index('chunked') != nil
          data = merge_chunk_data(data)
        end 

        return data
      end

      def merge_chunk_data(data) 
        chunk_size = 0
        result = ''

        len = "\r\n".length
        while (true)
          index = data.index("\r\n")

          chunked_size = "0x#{data[0, index]}"
          chunked_size = Integer(chunked_size)

          if (chunked_size == 0)
            break
          end

          start = index + len
          result << data[start, chunked_size]
          start = start + chunked_size + len
          data = data[start, data.length  - start]
        end

        return result
      end
    end
  end
end

