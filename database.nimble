# Package

version       = "0.1.0"
author        = "Grabli66"
description   = "Subject oriented database"
license       = "MIT"

# Dependencies

requires "nim >= 0.17.0", "websocket", "variant"
srcDir = "./database"
binDir = "../dist"
bin = @["database.exe"]