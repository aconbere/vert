package = "Vert"

version = "0.0.3-2"

source = { url = "git://github.com/aconbere/vert.git"
         , tag = "v0.0.3"
         }

description = { summary = "Creates isolated development environment"
              , detailed = [[
                  Vert is a tool for building isolated development environments akin to
                  virtualenv in python. It handles compiling and install lua to a local
                  directory as well as setting up luarocks.
                ]]
              , license = "MIT/X11"
              , maintainer = "Anders Conbere <aconbere@gmail.com>"
              }

dependencies = { "lua >= 5.1"
               , "luafilesystem"
               , "luasocket"
               }

build = { type = "builtin"
        , modules = { optimal         = "./src/optimal.lua"
                    , utils           = "./src/utils.lua"
                    , vert_initialize = "./src/vert_initialize.lua"
                    , vert_list       = "./src/vert_list.lua"
                    , vert_make       = "./src/vert_make.lua"
                    , vert_remove     = "./src/vert_remove.lua"
                    , vert            = "./src/vert.lua"
                    }

        , install = { bin = { vert         = "src/vert.lua"
                            , vert_wrapper = "src/vert_wrapper.sh"
                            }
                    }
        }
