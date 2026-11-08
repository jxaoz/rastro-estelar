local layer = CreateFrame("Frame", nil, UIParent)
layer:SetAllPoints(UIParent)
layer:SetFrameStrata("TOOLTIP")
layer:EnableMouse(false)

local spacing, lifetime = 13, 0.48
local colors = {
    {1, .36, .65}, {.69, .47, 1}, {.36, .78, 1},
    {.40, 1, .75}, {1, .85, .35},
}
local stars, nextStar, nextColor = {}, 1, 1
local previousX, previousY, carry
local enabled = true

for i = 1, 72 do
    local texture = layer:CreateTexture(nil, "ARTWORK")
    texture:SetTexture([[Interface\AddOns\RastroEstelar\Star.tga]])
    texture:Hide()
    stars[i] = {texture = texture}
end

local function Emit(x, y)
    local star = stars[nextStar]
    local color = colors[nextColor]
    nextStar = nextStar % #stars + 1
    nextColor = nextColor % #colors + 1
    star.x, star.y, star.age = x, y, 0
    star.size = math.random(12, 22)
    star.drift = math.random(-18, 18)
    star.texture:SetVertexColor(unpack(color))
    star.texture:SetRotation(math.random() * math.pi)
end

local function Update(_, elapsed)
    local x, y = GetCursorPosition()
    local scale = layer:GetEffectiveScale()
    x, y = x / scale, y / scale
    if x >= 0 and y >= 0 and x <= layer:GetWidth() and y <= layer:GetHeight() then
        if previousX then
            local dx, dy = x - previousX, y - previousY
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance > 0 then
                local first = math.max(spacing - carry, distance - spacing * 11)
                for offset = first, distance, spacing do
                    Emit(previousX + dx * offset / distance, previousY + dy * offset / distance)
                end
                carry = (carry + distance) % spacing
            end
        else
            carry = 0
        end
        previousX, previousY = x, y
    else
        previousX, previousY = nil, nil
    end

    for _, star in ipairs(stars) do
        if star.age then
            local age = star.age
            if age >= lifetime then
                star.age = nil
                star.texture:Hide()
            else
                local remaining = 1 - age / lifetime
                local size = star.size * (.35 + .65 * remaining)
                local texture = star.texture
                texture:ClearAllPoints()
                texture:SetPoint("CENTER", layer, "BOTTOMLEFT",
                    star.x + star.drift * age, star.y - 28 * age * age)
                texture:SetSize(size, size)
                texture:SetAlpha(remaining * remaining)
                texture:Show()
                star.age = age + elapsed
            end
        end
    end
end

layer:SetScript("OnUpdate", Update)
layer:SetScript("OnHide", function()
    previousX, previousY = nil, nil
    for _, star in ipairs(stars) do
        star.age = nil
        star.texture:Hide()
    end
end)

SLASH_RASTROESTELAR1 = "/estrelinhas"
SlashCmdList.RASTROESTELAR = function()
    enabled = not enabled
    layer:SetShown(enabled)
    print("Rastro Estelar " .. (enabled and "ligado." or "desligado."))
end
