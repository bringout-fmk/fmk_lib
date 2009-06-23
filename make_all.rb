files = Dir["fmk_*"]
files.each do |f| system("mingw32-make -C #{f} install") end

