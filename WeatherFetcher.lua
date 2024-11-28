local http_request = require "http.request"
local cjson = require "cjson"
local environment = require "environment"

local WeatherFetcher = {}
WeatherFetcher.__index = WeatherFetcher

-- constructor
function WeatherFetcher:new(api_key,format,lang)
    assert(api_key, "API key is required")
    local obj = {
        api_key = api_key,
        city = nil,
        format = format or "metric",
        lang = lang or "LT",
        latitude = nil, -- ex. 54.901727192586044
        longitude = nil, -- ex. 23.932813719674378
        zip = nil, -- ex 20011
        country_code = country_code, -- US
        endpoint = "https://api.openweathermap.org/data/2.5/forecast"
    }
    setmetatable(obj, self)
    return obj
end

-- api url build
function WeatherFetcher:build_url(type)

    -- build url with endpoint and language
    local url = string.format("%s?lang=%s&units=%s", self.endpoint,self.lang,self.format)

    -- append to url choice of location
    if type == "coordinates" then
        assert(self.latitude and self.longitude, "Latitude and Longitude must be set for coordinates")
        url = url .. string.format("&lat=%s&lon=%s",self.latitude,self.longitude)
    elseif type == "ZIP" then
        assert(self.zip, "ZIP code must be set for ZIP")
        url = url .. string.format("&zip=%s,%s",self.zip,self.country_code)
    elseif type == "city" then
        local city_no_white_space = self.city:gsub("%s","+") -- replace whitespaces with '+' symbol for api url ex. (new york) = new+york
        url = url .. string.format("&q=%s",city_no_white_space)
    else
        print("Invalid Location Type.")
    end

    -- append api key
    url = url .. string.format("&appid=%s",self.api_key)
    -- print(url)
    return url
end

function WeatherFetcher:fetch_weather_data(type)
    local url = self:build_url(type)
    local headers, stream = assert(http_request.new_from_uri(url):go())
    local body = assert(stream:get_body_as_string())
    
    if headers:get(":status") ~= "200" then
        error("Failed to fetch weather data HTTP status: " .. headers:get(":status"))
    end

    return cjson.decode(body)
end

function WeatherFetcher:process_weather_data(type)

    local data = self:fetch_weather_data(type)

    -- temperature symbol based on format
    local temp_symbol = ""
    if self.format == "metric" then
        temp_symbol = "°C"
    elseif self.format == "imperial" then
        temp_symbol = "°F"
    else
        temp_symbol = "K" 
    end

    -- table headers
    print("\nWeather Forecast: ")
    print(string.format("%-20s | %-20s| %-15s | %-30s", "Date", "City", "Temperature", "Description"))
    print(string.rep("-",91))

    for _, forecast in ipairs(data.list) do
        local timestamp = os.date("%Y-%m-%d %H:%M", forecast.dt)
        local temperature = string.format("%.2f %s",forecast.main.temp,temp_symbol)
        local description = forecast.weather[1].description

        print(string.format("%-20s | %-20s | %-15s | %-30s", timestamp, data.city.name, temperature, description))
    end
    print(string.rep("-",91))

end
-- local function main()

--     local api_key = environment.api_key
--     local format = environment.format or "metric"
--     local lang = environment.lang or "LT"

--     local success, err = pcall(function()
--         local weather_fetcher = WeatherFetcher:new(api_key,format,lang)
--         weather_fetcher:process_weather_data("ZIP")
--     end)

--     if not success then
--         print("An errod occurred: " .. err)
--     end

-- end

-- main()
return WeatherFetcher