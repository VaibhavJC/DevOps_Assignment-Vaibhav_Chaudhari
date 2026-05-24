resource "aws_ebs_volume" "orphaned_ebs" {
    availability_zone = var.ebs_availability_zone
    size              = var.ebs_size

    tags = {
        Name = "orphaned-ebs"
    }
}
