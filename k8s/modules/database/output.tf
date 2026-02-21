output "rds_endpoint" { 
  value       = aws_db_instance.postgres.endpoint
  description = "Connection endpoint for the PostgreSQL database"
}

output "pinecone_index_host" {
  value       = pinecone_index.vector_db.host
  description = "Host URL for the Pinecone vector database"
}
