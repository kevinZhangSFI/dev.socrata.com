link_dir := $(shell mktemp -d /tmp/linkdoc.XXXX)

# Builds SASS->CSS, compiles the site, and ensures that search.json is updated
# If you've changed content, always commit search.json
all:
	-rm search.json
	-rm related.json
	bundle exec jekyll build
	cp public/search.json public/related.json .
	-git add search.json related.json
	-tput bel

# Builds the site and runs linklint to check for bad links
test: all
	bundle exec htmlproof ./public --only-4xx --check-html --href-ignore "#" --href-ignore "/"

# Copies JS resources locally so you don't have to do a full jekyll build when hacking JS
jslocal:
	cp js/* public/js/
	cp common/js/* public/common/js/
	cp foundry/*.mst public/foundry/

# Pushes updated taglines file. Since this requires my password, you (probably) can't run it...
taglines:
	curl --user chris.metcalf@socrata.com -X PUT --data @taglines.json --header "Content-type: application/json" --header "X-App-Token: bjp8KrRvAPtuf809u1UXnI0Z8" https://soda.demo.socrata.com/resource/etih-7ix2.json

# Generates a build stamp and plugs it into a file in public
stamp:
	echo "SHA: `git rev-parse HEAD`" > ./public/build.txt
	echo "Date: `date`" >> ./public/build.txt
