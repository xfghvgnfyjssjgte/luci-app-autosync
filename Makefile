include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI app for AutoSync
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
