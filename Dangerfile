# frozen_string_literal: true

warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

warn("Big PR") if git.lines_of_code > 1000

raise("fdescribe left in tests") if `grep -r fdescribe specs/ `.length > 1
raise("fit left in tests") if `grep -r fit specs/ `.length > 1
raise("pry left in tests") if `grep -r pry specs/ `.length > 1

simplecov.report("coverage/coverage.json")
