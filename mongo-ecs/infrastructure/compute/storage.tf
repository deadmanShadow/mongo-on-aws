resource "aws_efs_file_system" "mongo_fs" {
  creation_token = "shard_efs"
  encrypted      = true
}


resource "aws_efs_mount_target" "fs_mount" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.mongo_fs.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [var.efs_sg_id]
}
