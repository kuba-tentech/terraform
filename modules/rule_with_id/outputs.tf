output "rule_id" {
  value = aws_security_group_rule.rule_with_id.*.id
}