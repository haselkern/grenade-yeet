VERSION = $(shell jq -r ".version" grenade-yeet/info.json)
NAME = $(shell jq -r ".name" grenade-yeet/info.json)

# build will create a properly named zip file by extracting the version
# information from info.json.
build:
	zip $(NAME)_$(VERSION).zip grenade-yeet/*
