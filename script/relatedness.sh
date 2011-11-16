#! /bin/sh

bundle exec rake relatedness:draw > /tmp/relatedness.dot
dot -Kfdp -Tsvg -o /tmp/relatedness.svg /tmp/relatedness.dot
# twopi is also nice:
#dot -Ktwopi -Tsvg -o relatedness.svg relatedness.dot
mv /tmp/relatedness.svg public/
