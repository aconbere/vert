#!/usr/bin/env lua

local lfs     = require("lfs")
local optimal = require("optimal")
local utils   = require("utils")

local C = { init     = require("vert_initialize")
          , make     = require("vert_make")
          , rm       = require("vert_remove")
          , ls       = require("vert_list")
          }

local help = [[usage: vert <command> [<args>]

The available subcommands are:
  make       Create a new virtualenv in ~/.verts   
  init       Make a new virtual environment
  rm         remove a virtual environment
  ls         Show a list of registered environments
]]

local opts = optimal.parse(...)

if not opts[1] then
  print(help)
  os.exit(0)
end

if not C[opts[1]] then
  print("vert: "..opts[1].." is not a vert command. See 'vert --help'.")
  os.exit(1)
end

local command = C[opts[1]]

command(opts)
