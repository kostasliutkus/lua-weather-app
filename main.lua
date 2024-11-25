local http_request = require "http.request"
local cjson = require "cjson"
local environment = require "environment"


local api_key = environment.api_key
local city = environment.city
local format = environment.format

local endpoint = "https://api.openweathermap.org/data/2.5/weather"
local url = string.format("%s?q=%s&appid=%s", endpoint, city, api_key)


local function fetch_weather_data(url)
    local headers, stream = assert(http_request.new_from_uri(url):go())
    local body = assert(stream:get_body_as_string())
    
    if headers:get(":status") ~= "200" then
        error("Error fetching data: " .. headers:get(":status"))
    end

    return body
end

local function main()
    local response = fetch_weather_data(url)
    local data = cjson.decode(response)
    
    print("City: " .. data.name)
    print("Temperature: " .. (data.main.temp - 273.15) .. "°C") -- Convert Kelvin to Celsius
    print("Weather: " .. data.weather[1].description)
end

main()
