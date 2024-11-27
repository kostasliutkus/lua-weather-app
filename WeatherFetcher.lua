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
        city = city or "Kaunas",
        format = format or "metric",
        lang = lang or "LT",
        latitude = latitude or "54.901727192586044",
        longitude = longitude or "23.932813719674378",
        zip = zip or "20011",
        country_code = country_code or "US",
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
        url = url .. string.format("&q=%s",self.city)
    else
        print("Invalid Location Type.")
    end

    -- append api key
    url = url .. string.format("&appid=%s",self.api_key)
    print(url)
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
    
    print("City: " .. data.city.name)
    print("Forecast: ")
    for _, forecast in ipairs(data.list) do
        local timestamp = os.date("%Y-%m-%d %H:%M:%S", forecast.dt)
        local temperature = forecast.main.temp
        local description = forecast.weather[1].description

        print(string.format("[%s] Temp: %.2f° %s, Weather: %s", timestamp, temperature, self.format == "metric" and "C" or "F", description))
    end

end
local function main()

    local api_key = environment.api_key
    local format = environment.format or "metric"
    local lang = environment.lang or "LT"

    local success, err = pcall(function()
        local weather_fetcher = WeatherFetcher:new(api_key,format,lang)
        weather_fetcher:process_weather_data("ZIP")
    end)

    if not success then
        print("An errod occurred: " .. err)
    end

end

main()
