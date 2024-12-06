terraform {
  cloud {
    organization = "lucasvinals"

    workspaces {
      project = "Main"
      name    = "exampledns"
    }
  }
}
module "dns" {
  source = "../../modules/dns"
}
