local http_request = require "http.request"
local cjson = require "cjson"
local environment = require "environment"

local WeatherFetcher = {}
WeatherFetcher.__index = WeatherFetcher

-- Constructor for WeatherFetcher
function WeatherFetcher:new(api_key, city, format)
    assert(api_key, "API key is required")
    local obj = {
        api_key = api_key,
        city = city or "Kaunas",
        format = format or "metric",
        endpoint = "https://api.openweathermap.org/data/2.5/weather"
    }
    setmetatable(obj, self)
    return obj
end

-- api url build
function WeatherFetcher:build_url()
    return string.format("%s?q=%s&appid=%s", self.endpoint, self.city, self.api_key)
end

function WeatherFetcher:fetch_weather_data()
    local url = self:build_url()
    local headers, stream = assert(http_request.new_from_uri(url):go())
    local body = assert(stream:get_body_as_string())
    
    if headers:get(":status") ~= "200" then
        error("Failed to fetch weather data HTTP status: " .. headers:get(":status"))
    end

    return cjson.decode(body)
end

function WeatherFetcher:process_weather_data()

    local data = self:fetch_weather_data()
    
    print("City: " .. data.name)
    if self.format == "metric" then
        print("Temperature: " .. (data.main.temp  - 273.15) .. "°C")
    elseif self.format == "imperial" then
        print("Temperature: " .. ((data.main.temp - 273.15) * 9/5 + 32) .. "°F")  -- Convert to Fahrenheit
    else
        print("Temperature: " .. data.main.temp .. " K")  -- Kelvin
    end
    
    print("Weather: " .. data.weather[1].description)

end
local function main()

    local api_key = environment.api_key
    local city = environment.city or "Kaunas"
    local format = environment.format or "metric"

    local success, err = pcall(function()
        local weather_fetcher = WeatherFetcher:new(api_key,city,format)
        weather_fetcher:process_weather_data()
    end)

    if not success then
        print("An errod occurred: " .. err)
    end

end

main()
