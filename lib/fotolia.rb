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


#
# Monkey patch XMLRPC::Client as Fotolia returns application/xml as content type
# instead of text/xml which XMLRPC expects
#
class XMLRPC::HTTPException < Exception #:nodoc:
end
class XMLRPC::HTTPAuthenticationException < Exception #:nodoc:
end
class XMLRPC::Client #:nodoc:
  private

  def do_rpc(request, async=false) #:nodoc:
    header = {
      "User-Agent"     =>  USER_AGENT,
      "Content-Type"   => "text/xml; charset=utf-8",
      "Content-Length" => request.size.to_s,
      "Connection"     => (async ? "close" : "keep-alive")
    }

    header["Cookie"] = @cookie        if @cookie
    header.update(@http_header_extra) if @http_header_extra

    if @auth != nil
      # add authorization header
      header["Authorization"] = @auth
    end

    resp = nil
    @http_last_response = nil

    if async
      # use a new HTTP object for each call
      Net::HTTP.version_1_2
      http = Net::HTTP.new(@host, @port, @proxy_host, @proxy_port)
      http.use_ssl = @use_ssl if @use_ssl
      http.read_timeout = @timeout
      http.open_timeout = @timeout

      # post request
      http.start {
        resp = http.post2(@path, request, header)
      }
    else
      # reuse the HTTP object for each call => connection alive is possible we
      # must start connection explicitely first time so that http.request does
      # not assume that we don't want keepalive
      @http.start if not @http.started?

      # post request
      resp = @http.post2(@path, request, header)
    end

    @http_last_response = resp

    data = resp.body

    if resp.code == "401"
      # Authorization Required
      raise XMLRPC::HTTPAuthenticationException, "Authorization failed.\nHTTP-Error: #{resp.code} #{resp.message}"
    elsif resp.code[0,1] != "2"
      raise XMLRPC::HTTPException, "HTTP-Error: #{resp.code} #{resp.message}"
    end

    ct = parse_content_type(resp["Content-Type"]).first
    if (ct != "text/xml")  && (ct != "application/xml")
      if ct == "text/html"
        raise "Wrong content-type (received '#{ct}' but expected 'text/xml'): \n#{data}"
      else
        raise "Wrong content-type (received '#{ct}' but expected 'text/xml')"
      end
    end

    expected = resp["Content-Length"] || "<unknown>"
    if data.nil? or data.size == 0
      raise XMLRPC::HTTPException, "Wrong size. Was #{data.size}, should be #{expected}"
    elsif expected != "<unknown>" and expected.to_i != data.size and resp["Transfer-Encoding"].nil?
      raise XMLRPC::HTTPException, "Wrong size. Was #{data.size}, should be #{expected}"
    end

    set_cookies = resp.get_fields("Set-Cookie")
    if set_cookies and !set_cookies.empty?
      require 'webrick/cookie'
      @cookie = set_cookies.collect do |set_cookie|
        cookie = WEBrick::Cookie.parse_set_cookie(set_cookie)
        WEBrick::Cookie.new(cookie.name, cookie.value).to_s
      end.join("; ")
    end

    return data
  end
end