module("luci.controller.autosync", package.seeall)

function index()
    -- Use nixio.fs to check for executable dependencies in a more robust way
    local nixio = require "nixio"

    -- Check for rsync
    if not nixio.fs.access("/usr/bin/rsync") then
        return
    end

    -- Check for inotifywait
    if not nixio.fs.access("/usr/bin/inotifywait") then
        return
    end

    -- If all dependencies are met, create the menu entry and load the CBI model.
    -- The .dependent=true flag ensures the menu item only shows if the controller
    -- successfully executes and the CBI model is found.
    entry({"admin", "services", "autosync"}, cbi("autosync/autosync"), _("AutoSync 自动同步"), 20).dependent = true
end