#
#  setup.rb
#
#  @author Mark Eissler
#
def stylesheets
  # Load the existing stylesheets while appending the custom one
  super + %w(css/custom.css)
end

def javascripts
  # Load the existing javascripts while appending the custom one
  super + %w(js/custom.js)
end
