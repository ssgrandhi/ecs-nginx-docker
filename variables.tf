variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_name" {
  description = "The VPC name to deploy the services. This is also used to lookup the terraform remote states."
  type        = string
}

variable "api_name" {
  description = "The apigateway name"
  type        = string
  default     = ""
}
/*
variable "http_method" {
type        = map(list(string))
  default = {}
}
*/
variable "http_method" {
  type = list(string)

}
variable "resourcepaths" {
  description = "path_part for api resource creation"
  //type        = list(string)))
  type    = list(string)
  default = []

}

variable "path_part" {
  description = "path_part for api resource creation"
  type = object({
    path        = list(string)
    http_method = string
  })
  default = {
    path        = ["a", "b"]
    http_method = "GET"
  }
}


/*
variable "resourcepaths" {
  description = "path_part for api resource creation"
  //type        = map(map(list(string)))
  type = map(list(string))
  default = {}

}
 */