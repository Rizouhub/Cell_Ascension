local _, Cell = ...
local F = Cell.funcs
local A = Cell.animations

-------------------------------------------------
-- pool
-------------------------------------------------
local pool

local function creationFunc()
    local f = CreateFrame("Frame")
    f:Hide()

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetTexture("Interface/AddOns/Cell/Media/star.png")
    tex:SetAllPoints(f)

    local ag = f:CreateAnimationGroup()
    ag:SetScript("OnFinished", function()
        if pool:IsActive(f) then
            pool:Release(f)
        end
    end)

    -- in -------------------------------------------------------------------- --
    local in_t = Cell.Polyfill.CreateAnimation(ag, "Translation")
    in_t:SetOrder(1)
    in_t:SetDuration(0.3)
    in_t:SetSmoothing("IN_OUT")

    local in_s = Cell.Polyfill.CreateAnimation(ag, "Scale")
    in_s:SetOrder(1)
    Cell.Polyfill.SetScaleFrom(in_s, 0, 0)
    Cell.Polyfill.SetScaleTo(in_s, 1, 1)
    in_s:SetDuration(0.3)

    local in_a = Cell.Polyfill.CreateAnimation(ag, "Alpha")
    in_a:SetOrder(1)
    Cell.Polyfill.SetFromAlpha(in_a, 0)
    Cell.Polyfill.SetToAlpha(in_a, 1)
    in_a:SetDuration(0.3)

    local in_spinning = Cell.Polyfill.CreateAnimation(ag, "Rotation")
    in_spinning:SetOrder(1)
    in_spinning:SetDegrees(-360)
    in_spinning:SetDuration(0.5)
    in_spinning:SetEndDelay(0.5)

    -- main ------------------------------------------------------------------ --
    local main_s1 = Cell.Polyfill.CreateAnimation(ag, "Scale")
    main_s1:SetOrder(2)
    Cell.Polyfill.SetScaleTo(main_s1, 1.25, 1.25)
    main_s1:SetDuration(0.2)

    local main_t1 = Cell.Polyfill.CreateAnimation(ag, "Translation")
    main_t1:SetOffset(0, 5)
    main_t1:SetDuration(0.1)
    main_t1:SetOrder(2)
    main_t1:SetSmoothing("OUT")

    local main_t2 = Cell.Polyfill.CreateAnimation(ag, "Translation")
    main_t2:SetOffset(0, -5)
    main_t2:SetDuration(0.1)
    main_t2:SetOrder(2)
    main_t2:SetSmoothing("IN")
    main_t2:SetStartDelay(0.1)
    main_t2:SetEndDelay(0.25)

    local main_s2 = Cell.Polyfill.CreateAnimation(ag, "Scale")
    main_s2:SetOrder(3)
    Cell.Polyfill.SetScaleTo(main_s2, 1.25, 1.25)
    main_s2:SetDuration(0.2)

    local main_t3 = Cell.Polyfill.CreateAnimation(ag, "Translation")
    main_t3:SetOffset(0, 5)
    main_t3:SetDuration(0.1)
    main_t3:SetOrder(3)
    main_t3:SetSmoothing("OUT")

    local main_t4 = Cell.Polyfill.CreateAnimation(ag, "Translation")
    main_t4:SetOffset(0, -5)
    main_t4:SetDuration(0.1)
    main_t4:SetOrder(3)
    main_t4:SetSmoothing("IN")
    main_t4:SetStartDelay(0.1)
    main_t4:SetEndDelay(0.5)

    -- out ------------------------------------------------------------------- --
    local out_s = Cell.Polyfill.CreateAnimation(ag, "Scale")
    out_s:SetOrder(4)
    Cell.Polyfill.SetScaleTo(out_s, 0, 0)
    out_s:SetDuration(0.5)
    out_s:SetSmoothing("IN")

    local out_spinning = Cell.Polyfill.CreateAnimation(ag, "Rotation")
    out_spinning:SetOrder(4)
    out_spinning:SetDegrees(-360)
    out_spinning:SetDuration(0.5)

    local out_t = Cell.Polyfill.CreateAnimation(ag, "Translation")
    out_t:SetOrder(4)
    out_t:SetStartDelay(0.2)
    out_t:SetDuration(0.3)
    out_t:SetSmoothing("IN_OUT")

    local out_a = Cell.Polyfill.CreateAnimation(ag, "Alpha")
    out_a:SetOrder(4)
    Cell.Polyfill.SetFromAlpha(out_a, 1)
    Cell.Polyfill.SetToAlpha(out_a, 0)
    out_a:SetStartDelay(0.2)
    out_a:SetDuration(0.3)

    function f:Display(x, y)
        in_t:SetOffset(x, y)
        out_t:SetOffset(x, -y)
        f:Show()
        ag:Play()
    end

    return f
end

local function resetterFunc(_, f)
    f:Hide()
end

pool = CreateObjectPool(creationFunc, resetterFunc)

local function Display(b)
    local f = pool:Acquire()
    f:SetParent(b.widgets.indicatorFrame)
    -- f:SetFrameLevel(b:GetFrameLevel()+200)
    f:SetPoint("CENTER", b, "BOTTOMLEFT")

    local size = max(min(b:GetHeight(), b:GetWidth()), 64)
    f:SetSize(size, size)

    f:Display(ceil(b:GetWidth()/2), ceil(b:GetHeight()/2))
    -- f:FadeIn()
    -- C_Timer.After(3, f.FadeOut)
end

-------------------------------------------------
-- mvp pool
-------------------------------------------------
local mvpPool = CreateObjectPool(function(pool)
    local f = CreateFrame("Frame")
    f:Hide()
    f:SetSize(128, 128)

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetTexture("Interface/AddOns/Cell/Media/FlipBooks/mvp.png")
    tex:SetAllPoints(f)
    Cell.Polyfill.SetParentKey(tex, "Flipbook")

    local mask = Cell.Polyfill.CreateMaskTexture(f)
    f.mask = mask
    mask:SetTexture(Cell.vars.whiteTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "TRILINEAR")
    Cell.Polyfill.AddMaskTexture(tex, mask)

    local ag = f:CreateAnimationGroup()
    ag:SetLooping("REPEAT")

    local flip = Cell.Polyfill.CreateAnimation(ag, "FlipBook")
    flip:SetDuration(2)
    Cell.Polyfill.SetFlipBookColumns(flip, 4)
    Cell.Polyfill.SetFlipBookRows(flip, 8)
    Cell.Polyfill.SetFlipBookFrames(flip, 32)
    Cell.Polyfill.SetChildKey(flip, "Flipbook")

    f:SetScript("OnShow", function()
        ag:Play()
        f.timer = C_Timer.NewTimer(3, f.FadeOut)
    end)

    A.CreateFadeIn(f, 0, 1, 0.2)
    A.CreateFadeOut(f, 1, 0, 0.2, nil, function()
        f.timer = nil
        if pool:IsActive(f) then
            pool:Release(f)
        end
    end)

    return f
end, function(_, f)
    if f.timer then
        f.timer:Cancel()
        f.timer = nil
    end
    f:Hide()
end)

local function DisplayMVP(b)
    local f = mvpPool:Acquire()
    f:SetParent(b.widgets.indicatorFrame)
    f:SetPoint("CENTER")
    f.mask:SetAllPoints(b.widgets.indicatorFrame)

    f:FadeIn()
end

-------------------------------------------------
-- goat pool
-------------------------------------------------
local goatPool = CreateObjectPool(function(pool)
    local f = CreateFrame("Frame")
    f:Hide()
    f:SetSize(128, 128)

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetTexture("Interface/AddOns/Cell/Media/FlipBooks/goat.png")
    tex:SetAllPoints(f)
    Cell.Polyfill.SetParentKey(tex, "Flipbook")

    local mask = Cell.Polyfill.CreateMaskTexture(f)
    f.mask = mask
    mask:SetTexture(Cell.vars.whiteTexture, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    Cell.Polyfill.AddMaskTexture(tex, mask)

    local ag = f:CreateAnimationGroup()
    ag:SetLooping("REPEAT")

    local flip = Cell.Polyfill.CreateAnimation(ag, "FlipBook")
    flip:SetDuration(2)
    Cell.Polyfill.SetFlipBookColumns(flip, 8)
    Cell.Polyfill.SetFlipBookRows(flip, 8)
    Cell.Polyfill.SetFlipBookFrames(flip, 52)
    Cell.Polyfill.SetChildKey(flip, "Flipbook")

    f:SetScript("OnShow", function()
        ag:Play()
        f.timer = C_Timer.NewTimer(3.8, f.FadeOut)
    end)

    A.CreateFadeIn(f, 0, 1, 0.2)
    A.CreateFadeOut(f, 1, 0, 0.2, nil, function()
        f.timer = nil
        if pool:IsActive(f) then
            pool:Release(f)
        end
    end)

    return f
end, function(_, f)
    if f.timer then
        f.timer:Cancel()
        f.timer = nil
    end
    f:Hide()
end)

local function DisplayGOAT(b)
    local f = goatPool:Acquire()
    f:SetParent(b.widgets.indicatorFrame)
    f:SetPoint("BOTTOMRIGHT")
    f.mask:SetAllPoints(b.widgets.indicatorFrame)

    f:FadeIn()
end

-------------------------------------------------
-- events
-------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("FIRST_FRAME_RENDERED")

local displays = {
    [true] = Display,
    ["mvp"] = DisplayMVP,
    ["goat"] = DisplayGOAT,
}

local function Check()
    pool:ReleaseAll()
    mvpPool:ReleaseAll()
    goatPool:ReleaseAll()

    -- Cell.wowSupporters[Cell.vars.playerNameFull] = true

    if IsInGroup() then
        for unit in F.IterateGroupMembers() do
            local fullName = F.UnitFullName(unit)
            if Cell.wowSupporters[fullName] then
                F.HandleUnitButton("unit", unit, displays[Cell.wowSupporters[fullName]])
            end
        end
    else
        if Cell.wowSupporters[Cell.vars.playerNameFull] then
            F.HandleUnitButton("unit", "player", displays[Cell.wowSupporters[Cell.vars.playerNameFull]])
        end
    end
end

local timer, members
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "FIRST_FRAME_RENDERED" then
        eventFrame:UnregisterEvent("FIRST_FRAME_RENDERED")
        eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    end

    if timer then
        timer:Cancel()
        timer = nil
    end

    if InCombatLockdown() then return end

    local newMembers = GetNumGroupMembers()
    if members ~= newMembers then
        members = newMembers
        timer = C_Timer.NewTimer(5, Check)
    end
end)