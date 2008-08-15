function test_screen

test_scr()

? "maksimiziraj prozor pa ponovo operaciju"
inkey(0)

test_scr()

return


static function test_scr()
? "init:"

? "maxrow", MaxRow()
? "maxcol", MaxCol()
? "pritisni nesto za nastavak"
inkey(0)

return
