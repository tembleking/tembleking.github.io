
_default:
	just -l

# Deploys a development server in localhost
serve: submodules
	hugo serve --buildDrafts --buildExpired --buildFuture

# Populates the git submodules
submodules:
	git submodule update --init

