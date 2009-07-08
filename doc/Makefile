all :   doc

doc :   bin/index.html

bin/index.html : src/index.txt src/style.css src/template.txt rest2web.ini
	r2w rest2web.ini -w
	cat bin/index.html | sed s/!REVISION!/`svn info src/index.txt | grep Revision | cut -c11-`/ > bin/index.html

clean : 
	rm -rf bin *.log
