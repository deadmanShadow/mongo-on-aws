
resource "aws_docdb_subnet_group" "mongo_grp" {
  name       = "mongo-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_docdb_cluster_instance" "mongo_instance" {
  count              = 1
  identifier         = "mongo-instance-1"
  cluster_identifier = "${aws_docdb_cluster.mongo_cluster.id}"
  instance_class     = "db.t3.medium"
}

resource "aws_docdb_cluster" "mongo_cluster" {
  skip_final_snapshot     = true
  db_subnet_group_name    = "${aws_docdb_subnet_group.mongo_grp.name}"
  cluster_identifier      = "mongo-app-cluster"
  engine                  = "docdb"
  master_username         = var.mongo_username
  master_password         = "${var.docdb_password}"
  db_cluster_parameter_group_name = "${aws_docdb_cluster_parameter_group.mongo_params.name}"
  vpc_security_group_ids = [var.mongo_sg_id]
}

resource "aws_docdb_cluster_parameter_group" "mongo_params" {
  family = "docdb5.0"
  name = "mongo-param-val"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}