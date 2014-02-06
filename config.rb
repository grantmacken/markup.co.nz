require 'singularitygs'
require 'breakpoint'
require 'color-schemer'
require 'breakpoint-slicer'
require 'omg-text'

http_path = "/"
css_dir = ".deploy/resources/styles"
sass_dir = "www/resources/styles"
images_dir = ".deploy/resources/images"
javascripts_dir = ".deploy/resources/scripts"
# You can select your preferred output style here (can be overridden via the command line):
output_style = :compact #:compressed #:expanded or :nested or :compact or :compressed
# To disable debugging comments that display the original location of your selectors. Uncomment:
line_comments = false
