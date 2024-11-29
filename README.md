### Prerequisites
Lua Environment: Ensure Lua 5.1 or higher is installed.
SQLite: Install SQLite and ensure the database is accessible.
Dependencies:
LuaSQL SQLite3
OpenWeatherMap API (requires an API key).

### Setup
Clone the repository:
`git clone https://github.com/yourusername/weather-app.git
cd weather-app`

### Install dependencies:

Set up LuaSQL SQLite3 as per your environment.
Obtain an API key from a weather provider (e.g., OpenWeatherMap).
Create the SQLite database:

Ensure the favorites table exists:
`
CREATE TABLE favorites (
    id INTEGER PRIMARY KEY,
    city TEXT UNIQUE
);`

### Configuration
Set up your API key, default format, language, and database path in the main.lua file or pass them programmatically.

### Usage
Run the application:

`lua main.lua`
Follow the menu options to:

Fetch weather by city name, ZIP code, or coordinates.
View, add, or delete favorite cities.
