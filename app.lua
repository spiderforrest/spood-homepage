local lapis = require("lapis")
local app = lapis.Application()

app:enable("etlua")

app.layout = require "views.layout"

-- directly render each etlua page shorthand function
local render = function () return { render = true } end

app:get("home", "/", render)

return app
