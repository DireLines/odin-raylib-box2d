make: atlas
	odin run .
atlas:
	odin run atlas_builder
	chmod +rw atlas.odin #not sure why it's being created with permissions 0x000
