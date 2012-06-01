#!/usr/bin/env lua

local lfs     = require("lfs")
local optimal = require("optimal")
local utils   = require("utils")

local C = { init     = require("vert_init")
          , make     = require("vert_make")
          , rm       = require("vert_rm")
          , ls       = require("vert_ls")
          }

local help = [[ usage: vert <command> [<args>]
The available subcommands are:
  register   
  init       Make a new virtual environment
  activate   Activate a virtual environment
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

command = C[opts[1]]

command(opts)
