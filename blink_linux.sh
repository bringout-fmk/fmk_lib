#!/bin/bash

#echo "Parametri $@"

CMD=$@

CMD2=$(echo $CMD | tr [/] [\\\\] )

echo ovo treba uraditi kao i clipper.rb ...
echo ustvari samo dodati builder.blink metod ...

dosemu -dumb -E "blinker $CMD2"
