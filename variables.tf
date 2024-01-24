variable "domain" {
  description = "The domain to create the SES identity for."
  type        = string
}

variable "zone_id" {
  type        = string
  description = "Route53 parent zone ID. If provided (not empty), the module will create Route53 DNS records used for verification."
  default     = ""
}

variable "verify_domain" {
  type        = bool
  description = "If provided the module will create Route53 DNS records used for domain verification."
  default     = false
}

variable "verify_dkim" {
  type        = bool
  description = "If provided the module will create Route53 DNS records used for DKIM verification."
  default     = false
}

variable "iam_permissions" {
  type        = list(string)
  description = "Specifies permissions for the IAM user."
  default     = ["ses:SendRawEmail"]
}

variable "iam_allowed_resources" {
  type        = list(string)
  description = "Specifies resource ARNs that are enabled for `var.iam_permissions`. Wildcards are acceptable."
  default     = []
}

variable "iam_access_key_max_age" {
  type        = number
  description = "Maximum age of IAM access key (seconds). Defaults to 30 days. Set to 0 to disable expiration."
  default     = 2592000

  validation {
    condition     = var.iam_access_key_max_age >= 0
    error_message = "The iam_access_key_max_age must be 0 (disabled) or greater."
  }
}

variable "ses_group_enabled" {
  type        = bool
  description = "Creates a group with permission to send emails from SES domain."
  default     = true
}

variable "ses_group_name" {
  type        = string
  description = "The name of the IAM group to create. If empty the module will calculate name from a context (recommended)."
  default     = ""
}

variable "ses_group_path" {
  type        = string
  description = "The IAM Path of the group to create."
  default     = "/"
}

variable "ses_user_enabled" {
  type        = bool
  description = "Creates user with permission to send emails from SES domain."
  default     = true
}

variable "mail_from_domain" {
  type        = string
  description = <<-EOT
    Subdomain (of the `domain`) which is to be used as MAIL FROM address (Required for DMARC validation).
    Specify only the subdomain part as the FQDN is inferred from the `domain` variable.
  EOT
  default     = ""
}

variable "behavior_on_mx_failure" {
  type        = string
  description = <<-EOT
    The action that you want Amazon SES to take if it cannot successfully read the required MX record when you send an email.
    Valid values are: `UseDefaultValue` and `RejectMessage`.
  EOT
  default     = "UseDefaultValue"
  validation {
    condition     = var.behavior_on_mx_failure == "UseDefaultValue" || var.behavior_on_mx_failure == "RejectMessage"
    error_message = "The behavior_on_mx_failure must be either `UseDefaultValue` or `RejectMessage`."
  }
}

variable "custom_spf_enabled" {
  type        = bool
  description = "Creates a Route53 SPF TXT entry for the custom MAIL FROM domain."
  default     = true
}

variable "custom_mx_enabled" {
  type        = bool
  description = "Creates a Route53 MX entry for the custom MAIL FROM domain."
  default     = true
}
