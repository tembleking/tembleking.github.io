
_default:
	just -l

# Deploys a development server in localhost
serve: _init-submodules
	hugo serve --buildDrafts --buildExpired --buildFuture

# Populates the git submodules
_init-submodules:
	git submodule update --init

update-submodules:
	git submodule update --init --remote

