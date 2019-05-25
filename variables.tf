variable "region" {
  default = "us-east-2"
}

variable "name" {
  default = "tf"
}

variable "allowed_cidr" {
  type = "list"

  default = [
    "0.0.0.0/0",
  ]
}

variable "image_tag" {
  default = "latest"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "log_retention" {
  default = 7
}

variable "login_email" {
  default = "admin@chain.link"
}

variable "env_vars" {
  type = "list"

  default = [
    ["ETH_CHAIN_ID", "3"],
    ["ETH_URL", "wss://ropsten-rpc.linkpool.io/ws"],
    ["LINK_CONTRACT_ADDRESS", "0x20fE562d797A42Dcb3399062AE9546cd06f63280"],
  ]
}