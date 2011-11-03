def within_select_with_no_selection(&block)
  within :xpath, XPath.generate { |x| x.descendant(:select)[~x.descendant(:option)[x.attr(:selected)]] }, &block
end

def within_select_with_selection(value, &block)
  within :xpath, XPath.descendant(:select)[XPath::HTML.option(value)], &block
end
