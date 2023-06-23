# Makefile CHEATSHEET: https://devhints.io/makefile
##############################################################################
# App : go test|run|build; docker build|push|pull|run|service|swarm|deploy
# ... all recipes for Docker and Golang builds, and app services (per se).
#
# For infra, configuration management (CM), and PostgreSQL HA,
# see Makefile(s) etal @ ./infra/, ./infra/docker/{nodes,services/stor/pgha}.
##############################################################################
include Makefile.settings
##############################################################################
# Meta

menu:
	$(INFO) 'Recipes'
	@echo '	getrefs   : Copy all REF* files to a tmp folder at ${TEMP}/$$( mktemp -d ).'
	@echo '	normalize : Strip fname prefix and reset internal links (of file-protocol)'

getrefs:
	refsync temp
	find ./REFs -type f -exec rm "{}" \+ 
	cp -p $$TEMP/$(shell ls $$TEMP -ahsrt --group-directories-first |grep tmp. |tail -n 1 |awk '{print $$NF}')/* ./REFs

normalize:
	find ./REFs -type f -iname '*.html' -exec rm "{}" \+
	find ./REFs -type f -iname '*.md' |xargs sed -i "s#file:///d:/1%20Data/IT.*/##g"
	find ./REFs -type f -iname '*.md' |xargs sed -i "s#file:///d:/1%20Data/.*/##g"
	cd ./REFs && fname 'REF.'

