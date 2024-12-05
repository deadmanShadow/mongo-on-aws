resource "aws_service_discovery_private_dns_namespace" "mongo_dns" {
  name = "mongo.dns"
  vpc  = var.vpc_id
}

resource "aws_service_discovery_service" "mongo_discovery" {
  name = "mongodb"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.mongo_dns.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}