require 'xmlrpc/client'

[
  'language',
  'base',
  'category',
  'conceptual_category',
  'representative_category',
  'categories',
  'conceptual_categories',
  'representative_categories',
  'color',
  'colors',
  'country',
  'countries',
  'gallery',
  'galleries',
  'medium',
  'tag',
  'tags',
  'search_result_set',
  'user'
].each {|file| require File.join(File.dirname(__FILE__), 'fotolia', file)}

require 'patron'

#
# Monkey patch XMLRPC::Client as Fotolia returns application/xml as content type
# instead of text/xml which XMLRPC expects
#
# Another monkey patch so that XMLRPC::Client will use the much faster Patron
# http client
#
class XMLRPC::HTTPException < Exception #:nodoc:
end
class XMLRPC::HTTPAuthenticationException < Exception #:nodoc:
end
module XMLRPC #:nodoc:
  class Client #:nodoc:
    def initialize(host=nil, path=nil, port=nil, proxy_host=nil, proxy_port=nil,
        user=nil, password=nil, use_ssl=nil, timeout=nil)

      @http_header_extra = nil
      @http_last_response = nil
      @cookie = nil

      @host       = host || "localhost"
      @path       = path || "/RPC2"
      @proxy_host = proxy_host
      @proxy_port = proxy_port
      @proxy_host ||= 'localhost' if @proxy_port != nil
      @proxy_port ||= 8080 if @proxy_host != nil
      @use_ssl    = use_ssl || false
      @timeout    = timeout || 30

      @port = port || (use_ssl ? 443 : 80)

      @user, @password = user, password

      # convert ports to integers
      @port = @port.to_i unless @port.nil?
      @proxy_port = @proxy_port.to_i unless @proxy_port.nil?

      # HTTP object for synchronous calls
      @http = build_http_client
      @http.handle_cookies

      @parser = nil
      @create = nil
    end

    def timeout=(new_timeout)
      @timeout = new_timeout
      @http.timeout = @timeout
    end

    private

    def set_auth
      if(@user.nil?)
        @http.username = nil
        @http.password = nil
      else
        @http.username = @user
        @http.password = @password
      end
    end

    def build_http_client
      http = Patron::Session.new
      require 'uri'
      http.base_url = URI::HTTP.build(
        :scheme => @use_ssl ? 'https' : 'http',
        :host   => @host,
        :port   => @port
      ).to_s
      http.timeout = @timeout
      unless(@proxy_host.nil?)
        http.proxy = URI::HTTP.build(:scheme => 'http', :host => @proxy_host, :port => @proxy_port).to_s
      end
      unless(@user.nil?)
        http.username = @user
        http.password = @password
      end

      http
    end

    def do_rpc(request, async=false) #:nodoc:
      header = {
        "User-Agent"     =>  USER_AGENT,
        "Content-Type"   => "text/xml; charset=utf-8",
        "Content-Length" => request.size.to_s,
        "Connection"     => (async ? "close" : "keep-alive")
      }

      header.update(@http_header_extra) if @http_header_extra

      resp = nil
      @http_last_response = nil

      resp = if async
        # use a new HTTP object for each call
        http = build_http_client

        # post request
        http.post(@path, request, header)
      else
        # reuse the HTTP object for each call => connection alive is possible we

        # post request
        @http.post(@path, request, header)
      end

      @http_last_response = resp

      data = resp.body

      if resp.status == 401
        # Authorization Required
        raise XMLRPC::HTTPAuthenticationException, "Authorization failed.\nHTTP-Error: #{resp.status} #{resp.status_line}"
      elsif resp.status < 200 or resp.status >= 300
        raise XMLRPC::HTTPException, "HTTP-Error: #{resp.status} #{resp.message}"
      end

      ct = parse_content_type(resp.headers["Content-Type"]).first
      if (ct != "text/xml")  && (ct != "application/xml")
        raise "Wrong content-type (received '#{ct}' but expected 'text/xml')"
      end

      expected = resp.headers["Content-Length"] || "<unknown>"
      if data.nil? or data.size == 0
        raise XMLRPC::HTTPException, "Wrong size. Was #{data.size}, should be #{expected}"
      elsif expected != "<unknown>" and expected.to_i != data.size and resp["Transfer-Encoding"].nil?
        raise XMLRPC::HTTPException, "Wrong size. Was #{data.size}, should be #{expected}"
      end

      return data
    end
  end
end