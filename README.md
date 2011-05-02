Fancycat.rb
===========

_Fancycat concatenates JavaScript files in large web applications. It parties with Octocat_


fancycat.rb is a script that reads our a list of template files
and concatenates them up into one nice package, bearing in mind
the best in DRY software. The goal of fancycat is to smartly
concatenate a project's JS files based on how they are included in 
the HTML template files of any modern framework. This means the HTML 
file itself is the build script. No more maintaining separate
build scripts.

blip.tv uses Varnish and ESIs, so we use the `<esi:comment>` tags
to separate our the different final JS files we want packaged up.

Example
--------

	<esi:comment text="Global.js" />
	<script src="BLIP.js" />
	<script src="BLIP/Object.js" />

	<esi:comment text="Dashboard.js" />
	<script src="Widget.js" />
	<script src="Doodad.js" />

This example causes fancycat.rb to package the BLIP.js and 
Object.js files into a file called Global.js and Widget.js and
Doodad.js into Dashboard.js. It is then recommended to minify this file 
using our standard [YUI compressor](http://developer.yahoo.com/yui/compressor/) or another minification tool.

Getting Started
---------------

Fancycat should be run on the commandline with your HTML templates as arguments. Example:


	kelly% fancycat.rb templ/blipnew/template1.phtml templ/blipnew/template2.phtml


blip.tv uses [Varnish](http://www.varnish-cache.org/) and [ESIs](http://bignosebird.com/sdocs/extend.shtml) in our stack, so we delimit new comments using ESI comments. 
You could potentially use HTML comments, Rails templates comments or random strings if
you feel like it. You will need to configure that yourself, though. 

These comments tell Fancycat where to stop and start concatenating files.

About
------

Fancycat.rb is used by [blip.tv](http://blip.tv) to concatenate their JavaScript for their
large applications. Originally written by Kelly Sutton.