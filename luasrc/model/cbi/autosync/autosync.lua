-- Copyright 2023-2024 Lienol <admin@lienol.com>
--
-- This is free software, licensed under the MIT License.

local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local nixio = require "nixio"

-- [[ LuCI CBI Model for AutoSync ]]
m = Map("autosync",
    translate("AutoSync Settings 自动同步设置"),
    translate("Real-time, one-way directory synchronization. 实时单向目录同步."))



-- [[ Sync Mappings Section ]]
s = m:section(TypedSection, "sync",
    translate("Sync Mappings 同步映射"),
    translate("Define multiple source-to-destination synchronization tasks. 定义多个源到目标的同步任务."))
s.template = "cbi/tblsection"
s.anonymous = true
s.addremove = true
s.sortable = true

-- Per-task Enable Switch
s:option(Flag, "enabled", translate("Enabled"))

-- Source Directory
o = s:option(Value, "src", translate("Source Directory 源目录"))
o.placeholder = "/mnt/usb/source_data"
o.datatype = "directory"
o.width = "100%"
function o.validate(self, value, section)
    value = value:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
    if value == "" or not value:match("^/") then
        return nil, translate("Please enter an absolute path starting with '/' (received: '" .. value .. "')")
    end
    local stat = nixio.fs.stat(value)
    if not stat or stat.type ~= "dir" then
        local stat_info = "(stat: " .. tostring(stat) .. ", type: " .. tostring(stat and stat.type) .. ")"
        return nil, translate("Source directory does not exist or is not a directory. " .. stat_info)
    end
    return value
end

-- Destination Directory
o = s:option(Value, "dest", translate("Destination Directory 目标目录"))
o.placeholder = "/mnt/nas/backup"
o.datatype = "directory"
o.width = "100%"
function o.validate(self, value, section)
    value = value:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
    if value == "" or not value:match("^/") then
        return nil, translate("Please enter an absolute path starting with '/' (received: '" .. value .. "')")
    end
    -- It's okay if the destination doesn't exist yet, rsync will create it.
    -- But we can warn the user if the parent doesn't exist.
    local parent = value:match("(.*/)[^/]+/?$")
    local parent_stat = nixio.fs.stat(parent)
    if parent and (not parent_stat or parent_stat.type ~= "dir") then
        local parent_stat_info = "(stat: " .. tostring(parent_stat) .. ", type: " .. tostring(parent_stat and parent_stat.type) .. ")"
        return nil, translate("Parent of destination directory does not exist. " .. parent_stat_info)
    end
    return value
end

-- Sync Deletes Switch
s:option(Flag, "sync_deletes",
    translate("Sync Deletes 同步删除"))

-- Per-task Sync Delay
o = s:option(Value, "delay",
    translate("Sync Delay (sec) 同步延迟（秒）"))
o.datatype = "uinteger"
o.placeholder = 5

-- Per-task Log File
o = s:option(Value, "logfile",
    translate("Log File Path 日志文件路径"))
o.placeholder = "/var/log/autosync.log"


return m