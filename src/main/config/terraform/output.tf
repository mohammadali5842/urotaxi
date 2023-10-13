output "db_endpoint" {
  value = aws_db_instance.urotaxidbec2.endpoint
}
output "javaserver_ip" {
  value = aws_instance.urotaxiec2.public_ip
}
output "mysql_engine_version" {
  value = aws_db_instance.urotaxidbec2.engine_version
}
output "db_ip" {
  value = aws_db_instance.urotaxidbec2.arn
}