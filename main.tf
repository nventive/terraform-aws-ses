locals {
  enabled              = module.this.enabled
  use_custom_mail_from = length(var.mail_from_domain) > 0 && local.enabled
  create_spf           = var.custom_spf_enabled && length(var.zone_id) > 0 && local.use_custom_mail_from && local.enabled
  create_mx            = var.custom_mx_enabled && length(var.zone_id) > 0 && local.use_custom_mail_from && local.enabled
  mail_from_domain     = join("", aws_ses_domain_mail_from.default.*.mail_from_domain)
}

data "aws_region" "current" {}

module "ses" {
  source  = "cloudposse/ses/aws"
  version = "0.24.0"

  domain                 = var.domain
  zone_id                = var.zone_id
  verify_domain          = var.verify_domain
  verify_dkim            = var.verify_dkim
  iam_permissions        = var.iam_permissions
  iam_allowed_resources  = var.iam_allowed_resources
  iam_access_key_max_age = var.iam_access_key_max_age
  ses_group_enabled      = var.ses_group_enabled
  ses_group_name         = var.ses_group_name
  ses_group_path         = var.ses_group_path
  ses_user_enabled       = var.ses_user_enabled

  context = module.this.context
}

resource "aws_ses_domain_mail_from" "default" {
  count = local.use_custom_mail_from ? 1 : 0

  domain           = var.domain
  mail_from_domain = "${var.mail_from_domain}.${var.domain}"
}

resource "aws_route53_record" "ses_domain_mail_from_mx" {
  count   = local.create_mx ? 1 : 0
  zone_id = var.zone_id
  name    = local.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${data.aws_region.current.id}.amazonses.com"]
}

resource "aws_route53_record" "ses_domain_mail_from_txt" {
  count   = local.create_spf ? 1 : 0
  zone_id = var.zone_id
  name    = local.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}
