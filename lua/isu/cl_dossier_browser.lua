-- cl_dossier_browser.lua

net.Receive("ISU_AllDossierKeys", function()
    local keys = net.ReadTable()

    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 500)
    frame:Center()
    frame:SetTitle("Dossier Browser")
    frame:MakePopup()

    local searchBox = vgui.Create("DTextEntry", frame)
    searchBox:SetSize(250, 24)
    searchBox:SetPos(20, 40)
    searchBox:SetPlaceholderText("Search by SteamID or name...")

    local filterBox = vgui.Create("DComboBox", frame)
    filterBox:SetSize(150, 24)
    filterBox:SetPos(290, 40)
    filterBox:AddChoice("All")
    filterBox:AddChoice("UNFLAGGED")
    filterBox:AddChoice("WATCHLIST")
    filterBox:AddChoice("WANTED")
    filterBox:AddChoice("ANTI-CITIZEN")
    filterBox:SetValue("All")

    local exportBtn = vgui.Create("DButton", frame)
    exportBtn:SetSize(100, 24)
    exportBtn:SetPos(460, 40)
    exportBtn:SetText("Export")
    exportBtn:SetEnabled(false)

    local list = vgui.Create("DListView", frame)
    list:SetSize(560, 380)
    list:SetPos(20, 80)
    list:AddColumn("SteamID")
    list:AddColumn("Flag")

    local function refreshList()
        list:Clear()
        local filter = filterBox:GetValue()
        local query = searchBox:GetValue():lower()

        for _, row in ipairs(keys) do
            local sid, flag = row[1], row[2]
            if (filter == "All" or flag == filter) and (query == "" or sid:lower():find(query)) then
                list:AddLine(sid, flag)
            end
        end
        exportBtn:SetEnabled(#list:GetLines() > 0)
    end

    searchBox.OnChange = refreshList
    filterBox.OnSelect = refreshList

    list.OnRowRightClick = function(_, line)
        local sid = list:GetLine(line):GetValue(1)
        net.Start("ISU_RequestDossier")
        net.WriteString(sid)
        net.SendToServer()
        frame:Close()
    end

    exportBtn.DoClick = function()
        local exportData = {}
        for _, line in ipairs(list:GetLines()) do
            table.insert(exportData, { line:GetValue(1), line:GetValue(2) })
        end

        net.Start("ISU_RequestExport")
        net.WriteTable(exportData)
        net.SendToServer()

        chat.AddText(Color(0, 255, 0), "[ISU] Dossiers exported.")
        surface.PlaySound("buttons/button14.wav")
    end

    refreshList()
end)
