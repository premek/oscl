local luaunit = require('test.luaunit')
luaunit.assertFalse(true)

os.exit( luaunit.LuaUnit.run() )

