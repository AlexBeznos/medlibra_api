c:
	pry --exec="require_relative './system/boot'"

test:
	bundle exec rspec spec/
