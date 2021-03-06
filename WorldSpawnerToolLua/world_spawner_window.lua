-- World Spawner Window
--
-- This window handles the world spawn areas. It is possible to select a planet, a map of that planet
-- is then shown together with the areas defined on that planet. Areas can be added, removed or
-- modified in this window.
--
-- This file should not contain any logic other than the creation and layout of the window and the
-- mapping of events for each control in the window.

require("object")
require("wx")

-- Control Id's, used to identify specific controls.
PLANET_SELECT_ID = 12345670
AREA_SELECT_ID = 12345671
AREA_SHAPE_ID = 12345672
LABEL1_ID = 12345673
LABEL2_ID = 12345674
XCOORD_ID = 12345675
YCOORD_ID = 12345676
INFO1_ID = 12345677
INFO2_ID = 12345678
AREA_TYPE_ID = 12345679
WSA_TYPE_ID = 12345680
BUILDINGS_ID = 12345681
SPAWN_GROUP_ID = 12345682
SAVE_BUTTON_ID = 12345683
NOF_SPAWNS_ID = 12345684

SCALE_FACTOR = 16  -- Image is 1024 x 1024 pixels. Real map is 16384 x 16384 coordinates.
OFFSET = 512       -- Image is 1024 x 1024 pixels.

-- Definition of the WorldSpawnerWindow class.
WorldSpawnerWindow = Object:new {
}

local function drawArea(dc, area, selected)
		selected = selected or false
    if area then
        x = 270 + OFFSET + area["x"] / SCALE_FACTOR
        y = 10 + OFFSET - area["y"] / SCALE_FACTOR
        r1w = math.max(area["size1"] / SCALE_FACTOR, 1)
        r2h = math.max(area["size2"] / SCALE_FACTOR, 1)
        local color = wx.wxColour(255, 255, 0)
        if selected then
        		color = wx.wxColour(255, 0, 0)
        end
    		dc:SetPen(wx.wxPen(color, 1, 0))
        if area["buildings"] == 1 then
        		dc:SetBrush(wx.wxBrush(color, wx.wxFDIAGONAL_HATCH))
        else
    				dc:SetBrush(wx.wxTRANSPARENT_BRUSH)
        end
        if area["shape"] == 1 then
            dc:DrawCircle(x, y, r1w)
        elseif area["shape"] == 2 then
            dc:DrawRectangle(x - r1w / 2, y - r2h / 2, r1w, r2h)
        elseif area["shape"] == 3 then
            dc:DrawCircle(x, y, r1w)
            dc:DrawCircle(x, y, r2h)
        end
    end
end

local function onPaintEventHandler(event)
    local dc = wx.wxPaintDC(WorldSpawnerWindow.panel)
    WorldSpawnerWindow.panel:PrepareDC(dc)
    dc:DrawBitmap(WorldSpawnerWindow.mapBitmap, 270, 10, false)

    if WorldSpawnerWindow.areaShapes then
        for i, area in pairs(WorldSpawnerWindow.areaShapes) do
            drawArea(dc, area)
        end
    end

    if WorldSpawnerWindow.selectedArea then
        drawArea(dc, WorldSpawnerWindow.selectedArea, true)
    end
end

local function enableAreaInfoControls(enable)
    WorldSpawnerWindow.xCoord:Enable(enable)
    WorldSpawnerWindow.yCoord:Enable(enable)
    WorldSpawnerWindow.areaShape:Enable(enable)
    WorldSpawnerWindow.areaShape:SetSelection(0)
    WorldSpawnerWindow.areaInfo1Value:Enable(enable)
    WorldSpawnerWindow.areaType:Enable(enable)
    WorldSpawnerWindow.worldSpawnType:Enable(enable)
    WorldSpawnerWindow.buildings:Enable(enable)
    WorldSpawnerWindow.spawnGroups:Enable(enable)
    WorldSpawnerWindow.nofSpawns:Enable(enable)
    WorldSpawnerWindow.areaInfo2Value:Enable(enable)
end

local function hideAreaInfoControls()
		enableAreaInfoControls(false)
    WorldSpawnerWindow.areaShape:SetSelection(0)
    WorldSpawnerWindow.areaInfo2Text:Show(false)
    WorldSpawnerWindow.areaInfo2Value:Show(false)
end

local function showAreaInfoControls()
		enableAreaInfoControls(true)
    if WorldSpawnerWindow.areaShape:GetSelection() == 0 then
        WorldSpawnerWindow.areaInfo1Text:SetLabel("Radius")
        WorldSpawnerWindow.areaInfo2Text:Show(false)
        WorldSpawnerWindow.areaInfo2Value:Show(false)
    elseif WorldSpawnerWindow.areaShape:GetSelection() == 1 then
        WorldSpawnerWindow.areaInfo1Text:SetLabel("Width")
        WorldSpawnerWindow.areaInfo2Text:SetLabel("Height")
        WorldSpawnerWindow.areaInfo2Text:Show(true)
        WorldSpawnerWindow.areaInfo2Value:Show(true)
    elseif WorldSpawnerWindow.areaShape:GetSelection() == 2 then
        WorldSpawnerWindow.areaInfo1Text:SetLabel("Inner Radius")
        WorldSpawnerWindow.areaInfo2Text:SetLabel("Outer Radius")
        WorldSpawnerWindow.areaInfo2Text:Show(true)
        WorldSpawnerWindow.areaInfo2Value:Show(true)
    end
end

local function areaUpdatedEventHandler()
		WorldSpawnerWindow.areaUpdatedEventHandler()
end

local function savePlanetEventHandler()
		WorldSpawnerWindow.savePlanetEventHandler()
end

local function updateSpawnGroupSelections(spawnGroups)
		for i = 0, WorldSpawnerWindow.spawnGroups:GetCount(), 1 do
				WorldSpawnerWindow.spawnGroups:Check(i, false)
				currentSpawnGroup = WorldSpawnerWindow.spawnGroups:GetString(i)
				for j, spawnGroup in pairs(spawnGroups) do
						if currentSpawnGroup == spawnGroup then
								WorldSpawnerWindow.spawnGroups:Check(i, true)
								break
						end
				end
		end
end

local function getEnabledSpawnGroups()
		local spawnGroups = {}
		for i = 0, WorldSpawnerWindow.spawnGroups:GetCount(), 1 do
				if WorldSpawnerWindow.spawnGroups:IsChecked(i) then
						table.insert(spawnGroups, WorldSpawnerWindow.spawnGroups:GetString(i))
				end
		end
		table.sort(spawnGroups)
		return spawnGroups
end

function WorldSpawnerWindow:create()
    wx.wxInitAllImageHandlers()

    self.window = wx.wxFrame(wx.NULL, wx.wxID_ANY, "SWGEmu World Spawner Tool",
                             wx.wxDefaultPosition, wx.wxSize(1300, 600))

    WorldSpawnerWindow.panel = wx.wxScrolledWindow(self.window, wx.wxID_ANY)
    WorldSpawnerWindow.panel:SetScrollbars(40, 40, 26, 26, 0, 0, true);
    WorldSpawnerWindow.panel:Connect(wx.wxEVT_PAINT, onPaintEventHandler)

    wx.wxStaticText(WorldSpawnerWindow.panel, wx.wxID_ANY, "Selected Planet", wx.wxPoint(10, 10))
    self.planetSelect = wx.wxComboBox(WorldSpawnerWindow.panel, PLANET_SELECT_ID, "Select a planet",
                                      wx.wxPoint(10, 30), wx.wxSize(250, 24))
    self.planetSelect:Connect(PLANET_SELECT_ID, wx.wxEVT_COMMAND_COMBOBOX_SELECTED,
                              function(event)
                              		hideAreaInfoControls()
                              		self.saveButton:Enable(true)
                                  self.planetSelectEventHandler(event:GetString())
                              end)

    wx.wxStaticText(WorldSpawnerWindow.panel, wx.wxID_ANY, "Selected Area", wx.wxPoint(10, 60))
    self.areaSelect = wx.wxComboBox(WorldSpawnerWindow.panel, AREA_SELECT_ID, "Select an area",
                                    wx.wxPoint(10, 80), wx.wxSize(250, 24))
    self.areaSelect:Enable(false)
    self.areaSelect:Connect(AREA_SELECT_ID, wx.wxEVT_COMMAND_COMBOBOX_SELECTED,
                            function(event)
                                self.areaSelectEventHandler(event:GetString())
                            end)

    wx.wxStaticText(WorldSpawnerWindow.panel, wx.wxID_ANY, "X", wx.wxPoint(10, 110))
    self.xCoord = wx.wxTextCtrl(WorldSpawnerWindow.panel, XCOORD_ID, "-", wx.wxPoint(10, 130),
                                wx.wxSize(120, 24))
		self.xCoord:Connect(XCOORD_ID, wx.wxEVT_COMMAND_TEXT_UPDATED, areaUpdatedEventHandler)

    wx.wxStaticText(WorldSpawnerWindow.panel, wx.wxID_ANY, "Y", wx.wxPoint(140, 110))
    self.yCoord = wx.wxTextCtrl(WorldSpawnerWindow.panel, YCOORD_ID, "-", wx.wxPoint(140, 130),
                                wx.wxSize(120, 24))
		self.yCoord:Connect(YCOORD_ID, wx.wxEVT_COMMAND_TEXT_UPDATED, areaUpdatedEventHandler)

    self.areaShape = wx.wxRadioBox(WorldSpawnerWindow.panel, AREA_SHAPE_ID, "Area Shape",
                                  wx.wxPoint(10, 160), wx.wxSize(250, 48),
                                  {"Circle", "Rectangle", "Ring"},
                                  1, wx.wxRA_SPECIFY_ROWS)
    self.areaShape:Connect(AREA_SHAPE_ID, wx.wxEVT_COMMAND_RADIOBOX_SELECTED,
                          function (event)
                          		areaUpdatedEventHandler(event)
                          		showAreaInfoControls()
                          end)

    self.areaInfo1Text = wx.wxStaticText(WorldSpawnerWindow.panel, LABEL1_ID, "Radius",
                                         wx.wxPoint(10, 210))
    self.areaInfo1Value = wx.wxTextCtrl(WorldSpawnerWindow.panel, INFO1_ID, "-", wx.wxPoint(10, 230),
                                        wx.wxSize(120, 24))
		self.areaInfo1Value:Connect(INFO1_ID, wx.wxEVT_COMMAND_TEXT_UPDATED, areaUpdatedEventHandler)

    self.areaInfo2Text = wx.wxStaticText(WorldSpawnerWindow.panel, LABEL2_ID, "Radius",
                                         wx.wxPoint(140, 210))
    self.areaInfo2Value = wx.wxTextCtrl(WorldSpawnerWindow.panel, INFO2_ID, "-", wx.wxPoint(140, 230),
                                        wx.wxSize(120, 24))
		self.areaInfo2Value:Connect(INFO2_ID, wx.wxEVT_COMMAND_TEXT_UPDATED, areaUpdatedEventHandler)

    self.areaType = wx.wxRadioBox(WorldSpawnerWindow.panel, AREA_TYPE_ID, "Area Type",
                                  wx.wxPoint(10, 260), wx.wxSize(250, 94),
                                  {"Undefined Area", "Spawn Area", "No Spawn Area"},
                                  3, wx.wxRA_SPECIFY_ROWS)
    self.areaType:Connect(AREA_TYPE_ID, wx.wxEVT_COMMAND_RADIOBOX_SELECTED, areaUpdatedEventHandler)

    self.worldSpawnType = wx.wxRadioBox(WorldSpawnerWindow.panel, WSA_TYPE_ID, "World Spawn Settings",
                                        wx.wxPoint(10, 360), wx.wxSize(250, 94),
                                        {"Allow World Spawns", "World Spawn Area", "No World Spawn Area"},
                                        3, wx.wxRA_SPECIFY_ROWS)
    self.worldSpawnType:Connect(WSA_TYPE_ID, wx.wxEVT_COMMAND_RADIOBOX_SELECTED, areaUpdatedEventHandler)

    self.buildings = wx.wxRadioBox(WorldSpawnerWindow.panel, BUILDINGS_ID, "Player Buildings",
                                   wx.wxPoint(10, 460), wx.wxSize(250, 71),
                                   {"Permitted", "Not Permitted"},
                                   2, wx.wxRA_SPECIFY_ROWS)
    self.buildings:Connect(BUILDINGS_ID, wx.wxEVT_COMMAND_RADIOBOX_SELECTED, areaUpdatedEventHandler)

    wx.wxStaticText(WorldSpawnerWindow.panel, wx.wxID_ANY, "Enabled Spawn Groups", wx.wxPoint(10, 540))
    self.spawnGroups = wx.wxCheckListBox(WorldSpawnerWindow.panel, SPAWN_GROUP_ID,
                                         wx.wxPoint(10, 560), wx.wxSize(250, 288), {}, wx.wxLB_MULTIPLE)
    self.window:Connect(wx.wxID_ANY, wx.wxEVT_COMMAND_CHECKLISTBOX_TOGGLED, areaUpdatedEventHandler)

    wx.wxStaticText(WorldSpawnerWindow.panel, wx.wxID_ANY, "Maximum Number of Spawns",
                    wx.wxPoint(10, 855))
    self.nofSpawns = wx.wxTextCtrl(WorldSpawnerWindow.panel, NOF_SPAWNS_ID, "-", wx.wxPoint(10, 875),
                                   wx.wxSize(250, 24))
		self.nofSpawns:Connect(NOF_SPAWNS_ID, wx.wxEVT_COMMAND_TEXT_UPDATED, areaUpdatedEventHandler)

    self.saveButton = wx.wxButton(WorldSpawnerWindow.panel, SAVE_BUTTON_ID, "Save Planet",
     															wx.wxPoint(10, 905), wx.wxSize(110, 30))
    self.saveButton:Enable(false)
    self.saveButton:Connect(SAVE_BUTTON_ID, wx.wxEVT_COMMAND_BUTTON_CLICKED, savePlanetEventHandler)

    hideAreaInfoControls()

    self.mapBitmap = wx.wxBitmap()

    self.areaInfo = nil
end

function WorldSpawnerWindow:getSelectedArea()
		return {
				name = self.areaSelect:GetValue(),
				x = self.xCoord:GetValue(),
				y = self.yCoord:GetValue(),
				size1 = self.areaInfo1Value:GetValue(),
				size2 = self.areaInfo2Value:GetValue(),
				shape = self.areaShape:GetSelection() + 1,
				type = self.areaType:GetSelection(),
				worldspawn = self.worldSpawnType:GetSelection(),
				buildings = self.buildings:GetSelection(),
				spawngroups = getEnabledSpawnGroups(),
				numberofspawns = self.nofSpawns:GetValue()
		}
end

function WorldSpawnerWindow:registerAreaUpdatedEventHandler(areaUpdatedEventHandler)
    self.areaUpdatedEventHandler = areaUpdatedEventHandler
end

function WorldSpawnerWindow:registerSelectedPlanetEventHandler(planetSelectEventHandler)
    self.planetSelectEventHandler = planetSelectEventHandler
end

function WorldSpawnerWindow:registerSelectedAreaEventHandler(areaSelectEventHandler)
    self.areaSelectEventHandler = areaSelectEventHandler
end

function WorldSpawnerWindow:registerSavePlanetEventHandler(savePlanetEventHandler)
		self.savePlanetEventHandler = savePlanetEventHandler
end

function WorldSpawnerWindow:setAreaNames(areaNames)
    self.areaSelect:Clear()
    self.areaSelect:Append(areaNames)
end

function WorldSpawnerWindow:setAreaShapes(areaShapes)
    self.areaSelect:Enable(true)
    self.areaShapes = areaShapes
    self.window:Refresh()
end

function WorldSpawnerWindow:setMapFile(mapFile)
    self.mapBitmap:LoadFile(mapFile, wx.wxBITMAP_TYPE_JPEG)
    self.window:Refresh()
end

function WorldSpawnerWindow:setPlanets(planets)
    self.planetSelect:Clear()
    self.planetSelect:Append(planets)
end

function WorldSpawnerWindow:setSelectedArea(area)
    showAreaInfoControls()
    self.selectedArea = area
    self.xCoord:ChangeValue(tostring(area["x"]))
    self.yCoord:ChangeValue(tostring(area["y"]))
    self.areaShape:SetSelection(area["shape"] - 1)
    self.areaInfo1Value:ChangeValue(tostring(area["size1"]))
    self.areaInfo2Value:ChangeValue(tostring(area["size2"]))
    self.areaType:SetSelection(area["type"])
    self.worldSpawnType:SetSelection(area["worldspawn"])
    self.buildings:SetSelection(area["buildings"])
    updateSpawnGroupSelections(area["spawngroups"])
    self.nofSpawns:ChangeValue(tostring(area["numberofspawns"]))
    self.window:Refresh()
end

function WorldSpawnerWindow:setSpawnGroups(spawnGroups)
		self.spawnGroups:Clear()
		self.spawnGroups:Append(spawnGroups)
end

function WorldSpawnerWindow:show()
    self.window:Show(true)
end

return WorldSpawnerWindow
