provider "grafana" {
  url  = "http://172.20.12.46/"
  auth = var.grafana_auth
}