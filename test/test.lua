local luaunit = require('test.luaunit')
luaunit.assertFalse(false)

os.exit( luaunit.LuaUnit.run() )

