local SQLiteDB = {}
SQLiteDB.__index = SQLiteDB

function SQLiteDB:new(db_path)

    local driver = require('luasql.sqlite3')
    local env = driver.sqlite3()
    local db = env:connect(db_path)

    if not db then
        error("Failed to connect to the database")
    end

    local instance = {
        env = env,
        db = db
    }
    setmetatable(instance,SQLiteDB)
    return instance
end

function SQLiteDB:execute_query(query)

    local cursor, err = self.db:execute(query)
    if not cursor then
        error("Failed to execute query: " .. (err or "unknown error"))
    end

    return cursor
end

function SQLiteDB:print_results(cursor)
    local id, name = cursor:fetch()
    while id do
        print(id .. ' | ' .. name)
        id, name = cursor:fetch()
    end
end

function SQLiteDB:close()
    if self.db then self.db:close() end
    if self.env then self.env:close() end
end

local function main()
    local success, err = pcall(function()
        local db = SQLiteDB:new('./test.db')
        local cursor = db:execute_query("SELECT * FROM test")
        db:print_results(cursor)
        cursor:close()
        db:close()
    )

end

main()