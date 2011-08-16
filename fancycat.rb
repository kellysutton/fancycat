#!/usr/bin/ruby

#
# fancycat.rb is a script that reads a list of template files
# and concatenates them up into one nice package, bearing in mind
# the best in DRY software. The goal of fancycat is to smartly
# concatenate a project's JS files based on how they are included in 
# the HTML template files of any modern framework. This means the HTML 
# file itself is the build script. No more maintaining separate
# build scripts.
#
# blip.tv uses Varnish and ESIs, so we use the <esi:comment> tags
# to separate our the different final JS files we want packaged up.
#
# Example:
#
#
#   ... 
#   <esi:comment text="Global.js" />
#   <script src="BLIP.js" />
#   <script src="BLIP/Object.js" />
#
#   <esi:comment text="Dashboard.js" />
#   <script src="Widget.js" />
#   <script src="Doodad.js" />
#  </body>
# </html>
#
# This example causes fancycat.rb to package the BLIP.js and 
# Object.js files into a file called Global.js and Widget.js and
# Doodad.js into Dashboard.js. It is then recommended to minify this file 
# using our standard YUI compressor or another minification tool.
#

require 'hpricot'

template_files = [
  'application.html.erb',
  'perl_template.phtml'
]

beginning_delimiter = /esi:comment.*\.js/
end_delimiter = /End JS/
target_dir = 'html/scripts/BLIP/'

# use the commandline parameters if we've got 'em
template_files = ARGV if ARGV.length > 0

files_to_generate = {}
current_file = ''

template_files.each do |format_file|
	done = false

	File.open(format_file).each_line do |s|

		if beginning_delimiter.match(s) and not end_delimiter.match(s) # we've found one of our special esi:comments
			h = Hpricot(s)	

			# See what our target file is
			(h/"esi:comment").each { |e| current_file = e.attributes['text'] } 
	
			files_to_generate[current_file] = []
		end

		if end_delimiter.match(s) 
			done = true		
		end
	
		if /script.*\.js/.match(s) and current_file != nil and current_file != '' and not /http/.match(s) and not done
			h = Hpricot(s)
			js_file = ''
			(h/:script).each { |f| js_file = f.attributes['src'] }

			# push the filename into the array of the current target file
			files_to_generate[current_file].push(js_file)
		end

	end

	# reset so the next format_file doesn't get confused
	current_file = nil
	
	files_to_generate.each do |file_to_gen, array|
		concat = ''


		# concat the files into a string
		array.each do |filename|
			File.open('html/' + filename) { |f| concat += f.read + "\n" } if filename != ''
		end

		# write out the concated string to a file
		myConcatFile = File.new(target_dir + file_to_gen, 'w')
		myConcatFile.write(concat)
		myConcatFile.close
	end
end
