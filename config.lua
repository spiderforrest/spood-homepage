local config = require("lapis.config")

config("development", {
  server = "nginx",
  code_cache = "off",
  port = 3000,
  num_workers = "1",
  session_name = "sess",
  secret = "secrmemt!!",
  ssl_eval = ''
})

config("prod", {
  server = "nginx",
  code_cache = "on",
  port = 80,
  num_workers = "4",
  session_name = "a0",
  secret = "wouldn't you like to know, weather boy",
  ssl_eval = [[listen 443 ssl;
    server_name         spood.org;
    ssl_certificate     fullchain.pem;
    ssl_certificate_key privkey.pem;
    ]], -- is treated as eval in nginx.conf. more details there.
})
