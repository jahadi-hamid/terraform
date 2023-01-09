output "hostnames-ips" {
  value = [
    for index, v in module.abrak-module.* :
    { "server-ip" : v.adresses.0,
      "server-name" : module.abrak-module[index].details-myabrak-id.name
    }
  ]


}

