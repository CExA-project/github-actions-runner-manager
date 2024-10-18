PREFIX ?= ${HOME}/.local
BIN = $(PREFIX)/bin

install:
	@install --verbose -D --target-directory $(BIN) --mode 755 manage-ghar

uninstall:
	@rm --force $(BIN)/manage-ghar
