verton () {
  env_name="$1"

  if [[ ! -n "$env_name" ]]
  then
    echo "ERROR: Vert name required"
    return 1
  fi

  activate="$HOME/.verts/$env_name/bin/activate"

  if [[ ! -f "$activate" ]]
  then
    echo "ERROR: Environment '$HOME/.verts/$env_name' does not contain an activate script." >&2
    return 1
  fi

  source "$activate"

  return 0
}
