resource "opentelekomcloud_cce_addon_v3" "metrics-server" {
  template_name    = "metrics-server"
  template_version = "1.3.6"
  cluster_id       = opentelekomcloud_cce_cluster_v3.cluster.id

  values {
    basic = {
      "image_version" : "v0.6.2",
      "swr_addr" : "100.125.7.25:20202",
      "swr_user" : "cce-addons"
    }
    custom = {}
  }
}

data "opentelekomcloud_cce_addon_template_v3" "autoscaler" {
  addon_version = "1.17.2"
  addon_name    = "autoscaler"
}

resource "opentelekomcloud_cce_addon_v3" "autoscaler" {
  template_name    = data.opentelekomcloud_cce_addon_template_v3.autoscaler.addon_name
  template_version = data.opentelekomcloud_cce_addon_template_v3.autoscaler.addon_version
  cluster_id       = opentelekomcloud_cce_cluster_v3.cluster.id

  values {
    basic = {
      "cceEndpoint" = "https://cce.${var.region_name}.otc.t-systems.com"
      "ecsEndpoint" = "https://ecs.${var.region_name}.otc.t-systems.com"
      "region"      = var.region_name
      "swr_addr"    = data.opentelekomcloud_cce_addon_template_v3.autoscaler.swr_addr
      "swr_user"    = data.opentelekomcloud_cce_addon_template_v3.autoscaler.swr_user
    }
    custom = {
      "cluster_id"                     = opentelekomcloud_cce_cluster_v3.cluster.id
      "coresTotal"                     = 32000
      "expander"                       = "priority"
      "logLevel"                       = 4
      "maxEmptyBulkDeleteFlag"         = 10
      "maxNodeProvisionTime"           = 15
      "maxNodesTotal"                  = 1000
      "memoryTotal"                    = 128000
      "scaleDownDelayAfterAdd"         = 10
      "scaleDownDelayAfterDelete"      = 11
      "scaleDownDelayAfterFailure"     = 3
      "scaleDownEnabled"               = true
      "scaleDownUnneededTime"          = 10
      "scaleDownUtilizationThreshold"  = 0.5
      "scaleUpCpuUtilizationThreshold" = 1
      "scaleUpMemUtilizationThreshold" = 1
      "scaleUpUnscheduledPodEnabled"   = true
      "scaleUpUtilizationEnabled"      = true
      "tenant_id"                      = data.opentelekomcloud_identity_project_v3.this.id
      "unremovableNodeRecheckTimeout"  = 5
    }
    flavor = <<EOF
      {
        "description": "Has only one instance",
        "name": "Single",
        "replicas": 1,
        "resources": [
          {
            "limitsCpu": "1000m",
            "limitsMem": "1000Mi",
            "name": "autoscaler",
            "requestsCpu": "500m",
            "requestsMem": "500Mi"
          }
        ]
      }
    EOF
  }
}


resource "opentelekomcloud_cce_addon_v3" "coredns" {
  template_name    = "coredns"
  template_version = "1.28.4"
  cluster_id       = opentelekomcloud_cce_cluster_v3.cluster.id

  values {
    basic = {
      "swr_addr" : "100.125.7.25:20202",
      "swr_user" : "hwofficial"
    }
    custom = {
      "stub_domains" : "{\"test\":[\"10.10.40.10\"], \"test2\":[\"10.10.40.20\"]}"
      "upstream_nameservers" : "[\"8.8.8.8\",\"8.8.4.4\"]"
    }
  }
}


data "opentelekomcloud_cce_addon_template_v3" "gpu" {
  addon_version = "2.0.46"
  addon_name    = "gpu-beta"
}

resource "opentelekomcloud_cce_addon_v3" "gpu" {
  template_name    = data.opentelekomcloud_cce_addon_template_v3.gpu[0].addon_name
  template_version = data.opentelekomcloud_cce_addon_template_v3.gpu[0].addon_version
  cluster_id       = opentelekomcloud_cce_cluster_v3.cluster.id

  values {
    basic = {
      "swr_addr" = data.opentelekomcloud_cce_addon_template_v3.gpu[0].swr_addr
      "swr_user" = data.opentelekomcloud_cce_addon_template_v3.gpu[0].swr_user
    }
    custom = {
      is_driver_from_nvidia      = true
      nvidia_driver_download_url = "https://us.download.nvidia.com/tesla/535.129.03/NVIDIA-Linux-x86_64-535.129.03.run"
    }
  }
}

data "opentelekomcloud_cce_addon_template_v3" "everest" {
  addon_version = "1.2.9"
  addon_name    = "everest"
}

resource "opentelekomcloud_cce_addon_v3" "everest" {
  template_name    = data.opentelekomcloud_cce_addon_template_v3.everest.addon_name
  template_version = data.opentelekomcloud_cce_addon_template_v3.everest.addon_version
  cluster_id       = opentelekomcloud_cce_cluster_v3.cluster.id

  values {
    basic = {
      "controller_image_version" = "1.2.9"
      "driver_image_version"     = "1.2.9"
      "swr_addr"                = "swr.${var.region_name}.otc.t-systems.com"
      "swr_user"                = "hwofficial"
    }

    custom = {
      "cluster_id"               = opentelekomcloud_cce_cluster_v3.cluster.id
      "project_id"               = data.opentelekomcloud_identity_project_v3.this.id
    }
  }
}