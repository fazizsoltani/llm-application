terraform {

  required_version = ">= 1.2.0"

  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = "1.36.33"
    }
  }

  backend "s3" {
    endpoint                    = "https://obs.eu-de.otc.t-systems.com"
    bucket                      = "terrafom-iac"
    key                         = "terraform/terraform.tfstate"
    region                      = "eu-de"
    use_lockfile                = true
  }

}