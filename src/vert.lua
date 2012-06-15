#!/usr/bin/env lua

local optimal = require("optimal")

local commands = { init = require("vert_initialize")
                 , make = require("vert_make")
                 , rm   = require("vert_remove")
                 , ls   = require("vert_list")
                 }

local help = [[usage: vert <command> [<args>]

The available subcommands are:
  make       Create a new virtualenv in ~/.verts
  init       Make a new virtual environment
  rm         remove a virtual environment
  ls         Show a list of registered environments
]]

local opts = optimal.parse(...)

local command = opts[1]

if not command then
  print(help)
  os.exit(1)
end

if not commands[command] then
  print("vert: "..command.." is not a vert command. See 'vert --help'.")
  os.exit(1)
end

commands[command].run(opts)
