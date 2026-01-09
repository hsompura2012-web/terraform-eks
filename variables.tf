variable "env" {
  default = "dev"
}



variable "ami" {
  default = "ami-09c813fb71547fc4f"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "vpc_security_group_ids"{
  default = [ "sg-07306e019683163e7" ]

}

variable "zone_id" {
  default =  "Z016760725VOFBIC0K9H4"

}

variable "Instance_Det" {
  default = {
    mongodb = ""
    redis = ""
    mysql = ""
    rabbitmq = ""
     }
}