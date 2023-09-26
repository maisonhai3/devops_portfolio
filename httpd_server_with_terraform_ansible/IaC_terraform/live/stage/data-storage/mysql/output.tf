output "address" {
    description = "Connect to the db at this endpoint."
    value = aws_db_instance.http_db.address
}

output "port" {
    description = "The db listens to this port."
    value = aws_db_instance.http_db.port
}