local WeatherApp = require("WeatherApp")
local environment = require("environment")

local app = WeatherApp:new(environment.api_key,environment.format,environment.lang)
app:run()