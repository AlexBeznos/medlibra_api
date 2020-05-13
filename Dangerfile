# frozen_string_literal: true

# rubocop:disable Style/SignalException
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

warn("Big PR") if git.lines_of_code > 1000

fail("fdescribe left in tests") if `grep -r fdescribe specs/ `.length > 1
fail("fit left in tests") if `grep -r fit specs/`.length > 1
fail("binding.pry left") if `grep -r binding.pry .`.length > 1

simplecov.report("coverage/coverage.json", sticky: false)
# rubocop:enable Style/SignalException
