function cm2str(xValue)

LOCAL cType := ValType( xValue )

DO CASE
   CASE cType == "D" 
         RETURN "STOD('" + DTOS( xValue ) + "')"
   OTHERWISE
         HB_ValToStr(xValue)
ENDCASE



function arg0(c)

return c


function setpxlat(c)
return c

