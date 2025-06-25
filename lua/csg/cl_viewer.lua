-- cl_viewer.lua
-- Styled Combine Surveillance Terminal UI with full feature set

local CSG_Frame, CSG_Cache

-- Build the terminal UI when we receive camera data
local function CreateSurveillanceUI(cameras)
    -- Clean up existing
    if IsValid(CSG_Frame) then CSG_Frame:Remove() end
    CSG_Cache = cameras

    -- Main Frame
    CSG_Frame = vgui.Create("DFrame")
    CSG_Frame:SetTitle("Surveillance Terminal")
    CSG_Frame:SetSize(ScrW() * 0.4, ScrH() * 0.7)
    CSG_Frame:Center()
    CSG_Frame:MakePopup()
    CSG_Frame:SetBackgroundBlur(true)

    -- Dark Combine-style paint
    CSG_Frame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 240))
        draw.RoundedBox(0, 0, 0, w, 24, Color(10, 10, 10, 200))
        draw.SimpleText(self:GetTitle(), "DermaLarge", 10, 4, Color(100, 200, 255), TEXT_ALIGN_LEFT)
    end

    -- Tab Sheet
    local sheet = vgui.Create("DPropertySheet", CSG_Frame)
    sheet:Dock(FILL)
    sheet:SetPadding(2)

    -- ==== TAB 1: Cameras ==== --
    local camPanel = vgui.Create("DPanel", sheet)
    camPanel:Dock(FILL)
    camPanel.Paint = function() end

    local camList = vgui.Create("DListView", camPanel)
    camList:Dock(FILL)
    camList:SetMultiSelect(false)
    camList:AddColumn("ID")
    camList:AddColumn("Label")
    camList:AddColumn("Position")
    for id, cam in pairs(cameras) do
        camList:AddLine(
            id,
            cam.label or "Unlabeled",
            string.format("(%d, %d, %d)", cam.pos.x, cam.pos.y, cam.pos.z)
        ).CameraID = cam.entIndex
    end

    -- Buttons Panel
    local btnPanel = vgui.Create("DPanel", camPanel)
    btnPanel:Dock(BOTTOM)
    btnPanel:SetTall(32)
    btnPanel.Paint = function() end

    -- View Button
    local viewBtn = vgui.Create("DButton", btnPanel)
    viewBtn:Dock(LEFT)
    viewBtn:DockMargin(4, 4, 4, 4)
    viewBtn:SetText("View")
    viewBtn.DoClick = function()
        local sel = camList:GetSelectedLine()
        if not sel then return end
        local id = tonumber(sel:GetColumnText(1))
        local cam = cameras[id]
        if not cam then return end

        local ent = Entity(cam.entIndex)
        if IsValid(ent) then
            LocalPlayer().CSG_ActiveCamera = ent
            -- Log view
            net.Start("CSG_LogCameraViewed")
            net.WriteUInt(id, 16)
            net.WriteString(cam.label or "")
            net.SendToServer()
        end
    end

    -- Ping Button
    local pingBtn = vgui.Create("DButton", btnPanel)
    pingBtn:Dock(LEFT)
    pingBtn:DockMargin(4, 4, 4, 4)
    pingBtn:SetText("Ping")
    pingBtn.DoClick = function()
        local sel = camList:GetSelectedLine()
        if not sel then return end
        local id = tonumber(sel:GetColumnText(1))
        local label = sel:GetColumnText(2)

        net.Start("CSG_PingCamera")
        net.WriteUInt(id, 16)
        net.WriteString(label)
        net.SendToServer()
    end

    -- Rename Button
    local renameBtn = vgui.Create("DButton", btnPanel)
    renameBtn:Dock(LEFT)
    renameBtn:DockMargin(4, 4, 4, 4)
    renameBtn:SetText("Rename")
    renameBtn.DoClick = function()
        local sel = camList:GetSelectedLine()
        if not sel then return end
        local id = tonumber(sel:GetColumnText(1))
        Derma_StringRequest(
            "Rename Camera",
            "Enter new label:",
            "",
            function(text)
                net.Start("CSG_RequestRenameCamera")
                net.WriteUInt(id, 16)
                net.WriteString(text)
                net.SendToServer()
            end
        )
    end

    sheet:AddSheet("Cameras", camPanel, "icon16/camera.png")

    -- ==== TAB 2: Logs ==== --
    local logPanel = vgui.Create("DPanel", sheet)
    logPanel:Dock(FILL)
    logPanel.Paint = function() end

    local logText = vgui.Create("DTextEntry", logPanel)
    logText:Dock(FILL)
    logText:SetMultiline(true)
    logText:SetEditable(false)
    if file.Exists(CSG_Config.DataPath .. "logs/camera_pings.txt", "DATA") then
        logText:SetText(file.Read(CSG_Config.DataPath .. "logs/camera_pings.txt", "DATA"))
    else
        logText:SetText("No logs available.")
    end

    sheet:AddSheet("Logs", logPanel, "icon16/report.png")
end

-- Request cameras when terminal is used
net.Receive("CSG_OpenTerminalUI", function()
    net.Start("CSG_RequestCameraList")
    net.SendToServer()
end)

-- Build the UI when we get the list
net.Receive("CSG_SendCameraList", function()
    local cams = net.ReadTable()
    CreateSurveillanceUI(cams)
end)

-- Override player view if viewing a camera
hook.Add("CalcView", "CSG_CameraView", function(ply, pos, angles, fov)
    local cam = ply.CSG_ActiveCamera
    if not IsValid(cam) then return end
    return { origin = cam:GetPos() + cam:GetUp() * 10,
             angles = cam:GetAngles(),
             fov = fov,
             drawviewer = true }
end)

-- Exit camera view with RMB or ESC
hook.Add("Think", "CSG_ExitCameraView", function()
    if (input.IsMouseDown(MOUSE_RIGHT) or input.IsKeyDown(KEY_ESCAPE))
       and IsValid(LocalPlayer().CSG_ActiveCamera) then
        LocalPlayer().CSG_ActiveCamera = nil
    end
end)

-- Draw camera label overlay
hook.Add("HUDPaint", "CSG_DrawCameraOverlay", function()
    local cam = LocalPlayer().CSG_ActiveCamera
    if not IsValid(cam) or not CSG_Cache then return end

    local label = "[UNKNOWN CAMERA]"
    for id, data in pairs(CSG_Cache) do
        if data.entIndex == cam:EntIndex() then
            label = data.label or label
            break
        end
    end

    surface.SetDrawColor(0, 0, 0, 180)
    surface.DrawRect(0, 0, ScrW(), 40)
    draw.SimpleText("SURVEILLANCE FEED – " .. label, "DermaLarge", 10, 10, Color(100, 200, 255), TEXT_ALIGN_LEFT)
end)

-- Confirm rename feedback
net.Receive("CSG_ConfirmRenameCamera", function()
    local id = net.ReadUInt(16)
    local newLabel = net.ReadString()
    chat.AddText(Color(100, 255, 100), "[CSG] Camera #" .. id .. " renamed to: " .. newLabel)
end)
