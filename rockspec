package = "Vert"

version = "0.0.1"

source = {
  url = "http://github.com/aconbere/vert",
}

description = {
  summary = "Creates isolated development environment",
  detailed = [[
    Vert is a tool for building isolated development environments akin to
    virtualenv in python. It handles compiling and install lua to a local
    directory as well as setting up luarocks.
  ]],
  license = "MIT/X11",
  maintainer = "Anders Conbere <aconbere@gmail.com>"
}

dependencies = {
   "lua == 5.1",
   "lfs",
   "luasocket"
}

build = {
  type = "builtin",
}
