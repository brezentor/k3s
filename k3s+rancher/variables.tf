variable "ami" {
 default  = "ami-0d527b8c289b4af7f"
 type     = string
}
variable "type" {
 default  = "t2.micro"
 type     = string
}
variable "key_name" {
 default  = "my-first-instance"
 type     = string
}
variable "vpc_security_group_ids" {
 default  = ["sg-0a658edcd5fceb23e"]
 type     = list(string)
}
variable "db_user" {
 default  = "brut"
 type     = string
}
variable "db_pass" {
 default  = "n7calfpaom"
 type     = string
}
variable "db_database" {
 default  = "test_cluster"
 type     = string
}
