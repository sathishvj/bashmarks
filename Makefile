INSTALL_DIR=~/.local/bin

all:
	@echo "Please run 'make install'"

install:
	@echo ""
	mkdir -p $(INSTALL_DIR)
	cp bashmarks.sh $(INSTALL_DIR)
	@echo ""
	@echo "Please add 'source $(INSTALL_DIR)/bashmarks.sh' to your .bashrc file"
	@echo ''
	@echo 'USAGE:'
	@echo '------'
	@echo 'sb <bookmark_name> - Saves the current directory as "bookmark_name"'
	@echo 'cb <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"'
	@echo 'pb <bookmark_name> - Prints the directory associated with "bookmark_name"'
	@echo 'db <bookmark_name> - Deletes the bookmark'
	@echo 'ob <bookmark_name> - Open bookmark in finder (mac only)'
	@echo 'lb                 - Lists all available bookmarks'

.PHONY: all install
