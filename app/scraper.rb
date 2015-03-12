require 'open-uri'
require 'nokogiri'
require_relative './shop'
class Scraper
  URL = "http://" #ほんとはターゲットのサイトのURLが入ってた

  attr_accessor :charset
  attr_reader :next

  #全件取得する
  def self.all_shops
    all_shops = []
    scraper = Scraper.new
    while scraper
      all_shops << scraper.parse!.shops      
      scraper = scraper.next_page
    end

    all_shops.flatten
  end

  def initialize(current_page = URL, prev_page = nil)    
    @charset  = ""
    @previous = prev_page
    @current  = current_page
    @next     = nil
    @doc      = nil
    @parsed   = false    
    @html     = open(@current) do |f|
      @charset = f.charset
      f.read
    end
    @shops = []
  end

  def parse!
    @doc = Nokogiri::HTML.parse(@html, nil, @charset)
    #next探し、何もなければnilのまま
    @next = @doc.xpath('//a[@class="nextpostslink"]').attribute('href').value unless @doc.xpath('//a[@class="nextpostslink"]').empty?
    @parsed = true

    self
  end

  def shops
    return nil unless parsed?
    return @shops unless @shops.empty?
    shops = []
    @doc.xpath('//div[@id="shop-listbox"]').each do |shop_listbox|
     shop_array = []
     shop_listbox.children.each  do |child|
        child.elements.each_with_index do |element,i|
          case i
          when 0
            shop_array << element.get_attribute('src')
            shop_array << element.inner_text.gsub("\n", "").gsub(" ","")
            shop_array << element.get_attribute('href')
          when 1
            shop_array << element.inner_text.gsub("\n", "").gsub(" ","")
          when 2
            shop_array << element.inner_text.split("\n")
          end
        end
      end
      formated_shop = shop_array.flatten.compact.delete_if{|s| s.empty? }
      shops << Shop.new(
               formated_shop[1], #name
               formated_shop[0], #image_url
               formated_shop[2].split("／")[0], #city
               formated_shop[2].split("／")[1], #near_station
               formated_shop[3], #address
               formated_shop[4].gsub("TEL：","").gsub(" ",""), #tel
               formated_shop[5], #wp_content_url
               )
    end
    @shops = shops
    shops
  end

  def parsed?
    @parsed
  end

  def next_page
    return nil unless parsed?
    return nil unless @next 
    next_page = Scraper.new(@next, @current)    
  end
end
