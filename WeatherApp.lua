local WeatherFetcher = require("WeatherFetcher") 
local WeatherApp = {}
WeatherApp.__index = WeatherApp


function WeatherApp:new(api_key,format,lang)
    assert(api_key, "API key is required")
    local obj = {
        api_key = api_key,
        format = format or "metric",
        lang = lang or "LT",
        favorite_cities = {},
        fetcher = nil
    }
    setmetatable(obj, WeatherApp)
    return obj
end


function WeatherApp:display_menu()
    print("\nWeather Forecast App")
    print("1. Get the forecast by city name")
    print("2. Get the forecast by ZIP code")
    print("3. Get the forecast by coordinates")
    print("4. View weather forecasts for your favorite cities")
    print("5. Add a new city to your favorite cities list")
    print("6. Delete a city from your favorite cities list")
    print("7. Exit")
    print("Enter your choice:")
end

function WeatherApp:handle_choice(choice)
    if choice == "1" then
        self:get_forecast_by_city()
    elseif choice == "2" then
        self:get_forecast_by_zip()
    elseif choice == "3" then
        self:get_forecast_by_coordinates()
    elseif choice == "4" then
        self:view_favorite_forecasts()
    elseif choice == "5" then
        self:add_to_favorites()
    elseif choice == "6" then
        self:remove_from_favorites()
    elseif choice == "7" then
        print("Exiting the program ...")
        os.exit()
    else
        print("Invalid choice. Please try again.")
    end
end

function WeatherApp:get_forecast_by_city()
    print("Enter city name:")
    local city = io.read()
    assert(city,"City name cannot be empty") -- fix citys with spaces ex. (new york) = new+york
    self.fetcher = WeatherFetcher:new(self.api_key,self.format,self.lang)
    self.fetcher.city = city
    self.fetcher:process_weather_data("city")
end

-- Get forecast by ZIP code
function WeatherApp:get_forecast_by_zip()
    print("Enter ZIP code:")
    local zip = io.read()
    self.fetcher = WeatherFetcher:new(self.api_key,self.format,self.lang)
    self.fetcher.zip = zip
    self.fetcher:process_weather_data("ZIP")
end

-- Get forecast by coordinates
function WeatherApp:get_forecast_by_coordinates()
    print("Enter latitude:")
    local latitude = io.read()
    print("Enter longitude:")
    local longitude = io.read()
    self.fetcher = WeatherFetcher:new(self.api_key,self.format,self.lang)
    self.fetcher.latitude = latitude
    self.fetcher.longitude = longitude
    self.fetcher:process_weather_data("coordinates")
end

function WeatherApp:run()
    while true do
        self:display_menu()
        local choice = io.read()
        local num_choice = tonumber(choice)
        if not num_choice or num_choice < 1 or num_choice > 7 then
            print("Invalid choice, please input a number")
        else
            self:handle_choice(choice)
        end
    end
end

return WeatherApp