include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "common" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_common/sg/sg.hcl"
}

feature "switch" {
  default = false
}

exclude {
  if      = !feature.switch.value
  actions = ["all_except_output"]
}
