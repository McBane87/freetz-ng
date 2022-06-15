$(call PKG_INIT_BIN, 21.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-src.tar.gz
$(PKG)_HASH:=4e8fc1beb80dc2af2d6a36a33a33f44dedddd4486002c644f4c4793043072025
$(PKG)_SITE:=https://github.com/nzbget/nzbget/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://nzbget.net/
### MANPAGE:=https://nzbget.net/documentation
### CHANGES:=https://github.com/nzbget/nzbget/releases
### CVSREPO:=https://github.com/nzbget/nzbget

$(PKG)_PATCH_POST_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(CXX|LD)FLAGS)

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)
$(PKG)_STAGING_WEBUI_DIR:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/nzbget
$(PKG)_TARGET_WEBUI_DIR:=$($(PKG)_DEST_DIR)/usr/share/nzbget
$(PKG)_TARGET_NZBGET_CONF:=$($(PKG)_TARGET_WEBUI_DIR)/nzbget.conf

$(PKG)_DEPENDS_ON += libxml2 $(STDCXXLIB) zlib
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_NZBGET_WITH_CURSES),ncurses)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_NZBGET_WITH_TLS),openssl)

$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NZBGET_WITH_CURSES
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NZBGET_WITH_TLS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NZBGET_DISABLE_PAR_CHECK
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NZBGET_STATIC

$(PKG)_CONFIGURE_ENV += LIBPREF="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NZBGET_WITH_CURSES),,--disable-curses)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NZBGET_WITH_TLS),--with-tlslib=OpenSSL,--disable-tls)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NZBGET_DISABLE_PAR_CHECK),--disable-parcheck,)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $(NZBGET_DIR)/.configured
	$(SUBMAKE) -C $(NZBGET_DIR) \
		EXTRA_CXXFLAGS="-fpermissive" \
		EXTRA_LDFLAGS="$(if $(FREETZ_PACKAGE_NZBGET_STATIC),-static)"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(NZBGET_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_NZBGET_CONF): $($(PKG)_STAGING_BINARY)
	mkdir -p $(NZBGET_TARGET_WEBUI_DIR)
	$(call COPY_USING_TAR,$(NZBGET_STAGING_WEBUI_DIR),$(NZBGET_TARGET_WEBUI_DIR) .)
	chmod 644 $@
	touch $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_NZBGET_CONF)


$(pkg)-clean:
	-$(SUBMAKE) -C $(NZBGET_DIR) clean
	$(RM) $(NZBGET_DIR)/.configured

$(pkg)-uninstall:
	$(RM) -r \
		$(NZBGET_TARGET_BINARY) \
		$(NZBGET_TARGET_WEBUI_DIR)

$(PKG_FINISH)
