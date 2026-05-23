resource "aws_ebs_volume" "orphaned_ebs" {
    availability_zone = var.availability_zone
    size              = var.size

    tags = {
        Name = "orphaned-ebs"
    }
}
