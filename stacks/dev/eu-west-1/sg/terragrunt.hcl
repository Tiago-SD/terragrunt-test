include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "common" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_common/sg/sg.hcl"
}
