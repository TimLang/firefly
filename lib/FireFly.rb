
require 'open-uri'

module FireFly
    VERSION = '0.01'

    def self.start_crawl start_url, options, &block
        spider = Core.new start_url, options
        block.call(spider)
        spider.start
    end

    module Util
    end

    module Event
        def bind

        end
    end

    module Filter
    end

    class Core
        include Util, Event, Filter

        attr_reader :todo_urls, :visited_urls, :filters

        def initialize start_url, options
            @todo_urls = [start_url]
            @visited_urls = {}
            @callbacks = {}
            @filters = []
        end

        def start
            begin
                base_url = @todo_urls.pop
                puts "visited: #{base_url}"
                begin
                    open(base_url).read.scan(/href=['|"](.+?)['|"]/) do |pending_url|
                        result_url = get_whole__url base_url, pending_url[0]
                        @todo_urls << result_url if result_url && !@visited_urls.has_key?(result_url)
                    end
                    #puts "todo size is #{@todo_urls.size}"
                rescue
                    puts 'error----------------'
                ensure
                    @visited_urls[base_url] = nil
                end
            end while !@todo_urls.empty?
        end

        def add_filters rep
            @filters.concat(rep).flatten
        end

        def is_relative_url url
            /^\// === url
        end

        def is_correct_url url
            #/^http/ === url && @filters.map{|f| f.call(url)}.all? 
            if !@filters.empty?
                @filters.map{|f| f === url}.all?
            else
               /^http/ === url 
            end
        end

        def get_whole__url current_url, url
            if is_correct_url(url)
                current_url.match(/(http:\/\/([^\/]+))\/?/)[1] << url if is_relative_url(url)     
                url 
            end
        end

        def test
            puts "im Tim Lang"
        end
    end    
end

puts "the version of Firefly is: #{FireFly::VERSION}"

FireFly.start_crawl 'http://www.yesmywine.com.hk', {} do |core|
    core.test
    core.add_filters [/www\.yesmywine\.com\.hk/]
end
