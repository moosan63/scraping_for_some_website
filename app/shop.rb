require 'json'
class Shop
  def initialize(name, image_url, city, near_station, address, tel, wp_content_url)
    @name             = name
    @image_url        = image_url
    @city             = city
    @near_station     = near_station
    @address          = address
    @tel              = tel
    @wp_content_url   = wp_content_url
    @latitude         = nil
    @longitude        = nil
  end

  def fetch_gps
  end

  def to_json
    {
                name: @name,
           image_url: @image_url,
                city: @city,
        near_station: @near_station,
             address: @address,
                 tel: @tel,
      wp_content_url: @wp_content_url,
            latitude: @latitude,
           longitude: @longitude,
    }.to_json
  end
end
