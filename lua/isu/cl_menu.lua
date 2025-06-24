-- cl_menu.lua

net.Receive("ISU_OpenDossier", function()
    local dossiers = net.ReadTable()
    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 530)
    frame:Center()
    frame:SetTitle("ISU Dossier Viewer")
    frame:MakePopup()

    local charID = LocalPlayer():SteamID64()
    local meta = dossiers._meta or {}
    local currentFlag = dossiers._flag or "UNFLAGGED"

    -- Search Other Dossiers
    local searchBtn = vgui.Create("DButton", frame)
    searchBtn:SetText("Search Others")
    searchBtn:SetSize(120, 20)
    searchBtn:SetPos(470, 5)
    searchBtn.DoClick = function()
        net.Start("ISU_RequestAllDossierKeys")
        net.SendToServer()
        frame:Close()
    end

    -- Flag Dropdown
    local flagLabel = vgui.Create("DLabel", frame)
    flagLabel:SetText("Flag:")
    flagLabel:SetPos(10, 30)
    flagLabel:SizeToContents()

    local flagBox = vgui.Create("DComboBox", frame)
    flagBox:SetPos(60, 30)
    flagBox:SetSize(200, 20)
    flagBox:AddChoice("UNFLAGGED")
    flagBox:AddChoice("WATCHLIST")
    flagBox:AddChoice("WANTED")
    flagBox:AddChoice("ANTI-CITIZEN")
    flagBox:SetValue(currentFlag)

    flagBox.OnSelect = function(_, _, value)
        net.Start("ISU_UpdateFlag")
        net.WriteString(charID)
        net.WriteString(value)
        net.SendToServer()
        chat.AddText(Color(0, 255, 0), "[ISU] Flag updated to: " .. value)
    end

    -- Metadata
    local factionEntry = vgui.Create("DTextEntry", frame)
    factionEntry:SetPos(320, 30)
    factionEntry:SetSize(120, 20)
    factionEntry:SetPlaceholderText("Faction")
    factionEntry:SetText(meta.faction or "")

    local locationEntry = vgui.Create("DTextEntry", frame)
    locationEntry:SetPos(450, 30)
    locationEntry:SetSize(120, 20)
    locationEntry:SetPlaceholderText("Last Location")
    locationEntry:SetText(meta.location or "")

    local commentEntry = vgui.Create("DTextEntry", frame)
    commentEntry:SetPos(10, 55)
    commentEntry:SetSize(560, 20)
    commentEntry:SetPlaceholderText("Comment / Behavior Notes")
    commentEntry:SetText(meta.comment or "")

    -- Save Button
    local saveBtn = vgui.Create("DButton", frame)
    saveBtn:SetText("Save Metadata")
    saveBtn:SetPos(480, 85)
    saveBtn:SetSize(90, 20)
    saveBtn.DoClick = function()
        net.Start("ISU_SubmitMetadata")
        net.WriteString(charID)
        net.WriteString(factionEntry:GetValue())
        net.WriteString(locationEntry:GetValue())
        net.WriteString(commentEntry:GetValue())
        net.SendToServer()
        chat.AddText(Color(0, 200, 255), "[ISU] Metadata saved.")
    end

    -- Dossier Log Viewer
    local list = vgui.Create("DListView", frame)
    list:SetPos(10, 115)
    list:SetSize(580, 400)
    list:AddColumn("Timestamp"):SetFixedWidth(160)
    list:AddColumn("Officer"):SetFixedWidth(160)
    list:AddColumn("Notes")

    for _, entry in ipairs(dossiers) do
        if type(entry) == "table" and entry.time and entry.officer and entry.notes then
            list:AddLine(entry.time, entry.officer, entry.notes)
        end
    end
end)

-- Dossier Search Panel
net.Receive("ISU_AllDossierKeys", function()
    local keys = net.ReadTable()

    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 400)
    frame:Center()
    frame:SetTitle("ISU Dossier Search")
    frame:MakePopup()

    local searchBox = vgui.Create("DTextEntry", frame)
    searchBox:SetPos(10, 30)
    searchBox:SetSize(480, 20)
    searchBox:SetPlaceholderText("Search SteamID or Name Fragment")

    local list = vgui.Create("DListView", frame)
    list:SetPos(10, 60)
    list:SetSize(480, 280)
    list:AddColumn("ID")
    list:AddColumn("Flag")

    local openBtn = vgui.Create("DButton", frame)
    openBtn:SetText("Open Dossier")
    openBtn:SetPos(10, 350)
    openBtn:SetSize(140, 30)

    local exportBtn = vgui.Create("DButton", frame)
    exportBtn:SetText("Export Dossier")
    exportBtn:SetPos(360, 350)
    exportBtn:SetSize(130, 30)

    local selected = nil

    local function RefreshList(query)
        list:Clear()
        for id, data in pairs(keys) do
            local match = string.find(id, query or "") or (data.name and string.find(string.lower(data.name), string.lower(query or "")))
            if match then
                list:AddLine(id, data.flag or "UNFLAGGED")
            end
        end
    end

    RefreshList("")

    searchBox.OnChange = function()
        RefreshList(searchBox:GetValue())
    end

    list.OnRowSelected = function(_, _, row)
        selected = row:GetColumnText(1)
    end

    openBtn.DoClick = function()
        if selected then
            net.Start("ISU_RequestDossier")
            net.WriteString(selected)
            net.SendToServer()
            frame:Close()
        end
    end

    exportBtn.DoClick = function()
        if selected then
            net.Start("ISU_RequestExport")
            net.WriteString(selected)
            net.SendToServer()
            chat.AddText(Color(0, 255, 255), "[ISU] Exported to /data/isu/logs/" .. selected .. ".txt")
        end
    end
end)

