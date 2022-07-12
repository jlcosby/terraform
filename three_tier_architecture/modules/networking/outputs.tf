# --- networking/outputs.tf ---

output "vpc" {
    value = aws_vpc.vpc.id
}

output "public_subnet_id" {
    value = [aws_subnet.web_subnet[0].id, aws_subnet.web_subnet[1].id]
}

output "private_subnet_id" {
    value = [aws_subnet.app_subnet[0].id, aws_subnet.app_subnet[1].id]
}
    
output "database_subnet_id" {
    value = [aws_subnet.database_subnet[0].id, aws_subnet.database_subnet[1].id]
}