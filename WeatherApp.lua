local WeatherFetcher = require("WeatherFetcher") 
local SQLiteDB = require("SQLiteDB") 

local WeatherApp = {}
WeatherApp.__index = WeatherApp

-- constructor
function WeatherApp:new(api_key,format,lang,db_path)
    assert(api_key, "API key is required")
    local obj = {
        api_key = api_key,
        format = format or "metric",
        lang = lang or "LT",
        db_path = db_path,
        sqlitedb = nil,
        fetcher = nil
    }
    setmetatable(obj, WeatherApp)
    return obj
end

-- function to display the choice menu
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

-- function to handle menu choice
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

-- get forecast by city name
function WeatherApp:get_forecast_by_city()
    print("Enter city name:")
    local city = io.read()
    assert(city,"City name cannot be empty") 
    self.fetcher = WeatherFetcher:new(self.api_key,self.format,self.lang)
    self.fetcher.city = city
    self.fetcher:process_weather_data("city")
end

-- get forecast by ZIP code
function WeatherApp:get_forecast_by_zip()

    print("Enter ZIP code:")
    local zip = io.read()
    assert(zip,"Please provide a ZIP code")

    print("Enter Country Code:")
    local country_code = io.read()
    assert(zip,"Please provide a Country code")

    self.fetcher = WeatherFetcher:new(self.api_key,self.format,self.lang)
    self.fetcher.zip = zip
    self.fetcher.country_code = country_code
    self.fetcher:process_weather_data("ZIP")
end

-- get forecast by coordinates
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

-- function to add a city to favorites
function WeatherApp:add_to_favorites()
    
    print("Enter the name of the city to add to your favorites:")
    local city = io.read()

    self.sqlitedb = SQLiteDB:new(self.db_path)

    local query = string.format("INSERT INTO favorites (city) VALUES ('%s')",city:gsub("'", "''"))

    self.sqlitedb:execute_query(query)
    self.sqlitedb:close()
    print(city .. " has been added to your favorite cities list.")
end

-- function to add a city to favorites
function WeatherApp:view_favorite_forecasts()

    self.sqlitedb = SQLiteDB:new(self.db_path)

    local query = "SELECT * FROM favorites"

    local cursor = self.sqlitedb:execute_query(query)

    local favorites = {}

    local row = cursor:fetch({},"a")

    while row do
        table.insert(favorites, row)
        row = cursor:fetch({}, "a") -- Fetch the next row
    end
    cursor:close()
    self.sqlitedb:close()

    self.fetcher = WeatherFetcher:new(self.api_key,self.format,self.lang)
    
    -- display favorites
    for _, favorite in ipairs(favorites) do     
        self.fetcher.city = favorite.city
        self.fetcher:process_weather_data("city")
    end

end

-- run app funciton
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