$(call PKG_INIT_BIN, $(if $(FREETZ_SAMBA_VERSION_3_0),3.0.37,3.6.3))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5_3.0.37:=11ed2bfef4090bd5736b194b43f67289
$(PKG)_SOURCE_MD5_3.6.3:=98ac9db9f4b6ebfc3f013aa193ffb0d1
$(PKG)_SOURCE_MD5:=$($(PKG)_SOURCE_MD5_$($(PKG)_VERSION))
$(PKG)_SITE:=http://samba.org/samba/ftp/stable

$(PKG)_CONDITIONAL_PATCHES+=$($(PKG)_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_SAMBA_VERSION_3_0
$(PKG)_REBUILD_SUBOPTS += FREETZ_SAMBA_VERSION_3_6

include $(MAKE_DIR)/samba/samba$(if $(FREETZ_SAMBA_VERSION_3_0),30,36).mk.in

$(PKG_FINISH)
