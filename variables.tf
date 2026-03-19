variable "env" {
  default = "dev"
}



variable "ami" {
  default = "ami-0220d79f3f480ecf5"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "vpc_security_group_ids"{
  default = [ "sg-05cd38b71975b0ff5" ]

}

variable "zone_id" {
  default =  "Z07818291SQAE6AN08Y8L"

}

variable "Instance_Det" {
  default = {
    mongodb = ""
    redis = ""
    mysql = ""
    rabbitmq = ""
     }
}