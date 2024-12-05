



output "subnet_ids"{
    value = aws_subnet.app_private.*.id
}

output public_subnet_ids{
    value = aws_subnet.app_public.*.id
}

output one_pub_subnet_id{
    value = aws_subnet.app_public[0].id
}

output "efs_sg_id"{
    value = aws_security_group.efs_mongo_sg.id
}

output vpc_id{
    value = aws_vpc.appvpc.id
}

output mongo_sg_id{
    value = aws_security_group.mongo_task_sg.id
}

output test_ec2_sg_id{
    value = aws_security_group.test_ec2_sg.id
}
