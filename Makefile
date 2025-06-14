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
	clear
	$(INFO) 'Recipes'
	@echo '	build     : getrefs index normalize'
	@echo '	getrefs   : Copy all REF* files to a tmp folder at ${TEMP}/$$( mktemp -d ).'
	@echo '	index     : Process MD files into HTML and create index.html'
	@echo '	normalize : Strip fname prefix and reset internal links (of file-protocol)'
	@echo '	commit    : git commit ... && git push ...'

build : getrefs index normalize

getrefs :
	bash make.recipes.sh getrefs

index :
	bash make.recipes.sh index

normalize :
	bash make.recipes.sh normalize

commit :
	bash make.recipes.sh gitpush
