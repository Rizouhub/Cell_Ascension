local addonName, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
---@class CellAnimations
local A = Cell.animations

-----------------------------------------
-- forked from ElvUI
-----------------------------------------
local FADEFRAMES, FADEMANAGER = {}, CreateFrame('FRAME')
FADEMANAGER.interval = 0.025

-----------------------------------------
-- fade manager onupdate
-----------------------------------------
local function Fading(_, elapsed)
    FADEMANAGER.timer = (FADEMANAGER.timer or 0) + elapsed

    if FADEMANAGER.timer > FADEMANAGER.interval then
        FADEMANAGER.timer = 0

        for frame, info in next, FADEFRAMES do
            if frame:IsVisible() then
                info.fadeTimer = (info.fadeTimer or 0) + (elapsed + FADEMANAGER.interval)
            else -- faster for hidden frames
                info.fadeTimer = info.timeToFade + 1
            end

            if info.fadeTimer < info.timeToFade then
                if info.mode == 'IN' then
                    frame:SetAlpha((info.fadeTimer / info.timeToFade) * info.diffAlpha + info.startAlpha)
                else
                    frame:SetAlpha(((info.timeToFade - info.fadeTimer) / info.timeToFade) * info.diffAlpha + info.endAlpha)
                end
            else
                frame:SetAlpha(info.endAlpha)
                -- NOTE: remove from FADEFRAMES
                if frame and FADEFRAMES[frame] then
                    if frame.fade then
                        frame.fade.fadeTimer = nil
                    end
                    FADEFRAMES[frame] = nil
                end
            end
        end

        if not next(FADEFRAMES) then
            -- print("FINISHED FADING!")
            FADEMANAGER:SetScript('OnUpdate', nil)
        end
    end
end

-----------------------------------------
-- fade
-----------------------------------------
local function FrameFade(frame, info)
    frame:SetAlpha(info.startAlpha)

    if not frame:IsProtected() then
        frame:Show()
    end

    if not FADEFRAMES[frame] then
        FADEFRAMES[frame] = info
        FADEMANAGER:SetScript('OnUpdate', Fading)
    else
        FADEFRAMES[frame] = info
    end
end

function A.FrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
    if frame.fade then
        frame.fade.fadeTimer = nil
    else
        frame.fade = {}
    end

    frame.fade.mode = 'IN'
    frame.fade.timeToFade = timeToFade
    frame.fade.startAlpha = startAlpha
    frame.fade.endAlpha = endAlpha
    frame.fade.diffAlpha = endAlpha - startAlpha

    FrameFade(frame, frame.fade)
end

function A.FrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
    if frame.fade then
        frame.fade.fadeTimer = nil
    else
        frame.fade = {}
    end

    frame.fade.mode = 'OUT'
    frame.fade.timeToFade = timeToFade
    frame.fade.startAlpha = startAlpha
    frame.fade.endAlpha = endAlpha
    frame.fade.diffAlpha = startAlpha - endAlpha

    FrameFade(frame, frame.fade)
end

-----------------------------------------
-- fade in/out on mouseover/mouseout
-----------------------------------------
function A.ApplyFadeInOutToParent(parent, condition, ...)
    for _, f in pairs({...}) do
        f:SetHitRectInsets(-2, -2, -2, -2)

        Cell.Polyfill.HookScript(f, "OnEnter", function()
            if condition() then
                A.FrameFadeIn(parent, 0.25, parent:GetAlpha(), 1)
            end
        end)

        Cell.Polyfill.HookScript(f, "OnLeave", function()
            if condition() then
                A.FrameFadeOut(parent, 0.25, parent:GetAlpha(), 0)
            end
        end)
    end
end

-----------------------------------------
-- add fade in/out
-----------------------------------------
function A.CreateFadeIn(frame, fromAlpha, toAlpha, duration, delay, onFinished)
    local fadeIn = frame:CreateAnimationGroup()
    frame.fadeIn = fadeIn
    fadeIn.alpha = Cell.Polyfill.CreateAnimation(fadeIn, "Alpha")
    Cell.Polyfill.SetFromAlpha(fadeIn.alpha, fromAlpha)
    Cell.Polyfill.SetToAlpha(fadeIn.alpha, toAlpha)
    fadeIn.alpha:SetDuration(duration)
    if delay then fadeIn.alpha:SetStartDelay(delay) end

    fadeIn:SetScript("OnPlay", function()
        if frame.fadeOut then
            frame.fadeOut:Stop()
        end
    end)

    if onFinished then
        fadeIn:SetScript("OnFinished", onFinished)
    end

    function frame:FadeIn()
        frame:Show()
        fadeIn:Play()
    end
end

function A.CreateFadeOut(frame, fromAlpha, toAlpha, duration, delay, onFinished)
    local fadeOut = frame:CreateAnimationGroup()
    frame.fadeOut = fadeOut
    fadeOut.alpha = Cell.Polyfill.CreateAnimation(fadeOut, "Alpha")
    Cell.Polyfill.SetFromAlpha(fadeOut.alpha, fromAlpha)
    Cell.Polyfill.SetToAlpha(fadeOut.alpha, toAlpha)
    fadeOut.alpha:SetDuration(duration)
    if delay then fadeOut.alpha:SetStartDelay(delay) end

    fadeOut:SetScript("OnPlay", function()
        if frame.fadeIn then
            frame.fadeIn:Stop()
        end
    end)

    if onFinished then
        fadeOut:SetScript("OnFinished", onFinished)
    else
        fadeOut:SetScript("OnFinished", function()
            frame:Hide()
        end)
    end

    function frame:FadeOut()
        fadeOut:Play()
    end
end

-----------------------------------------
-- apply fade in/out to menu
-----------------------------------------
function A.ApplyFadeInOutToMenu(anchorFrame, hoverFrame)
    local fadingIn, fadedIn, fadingOut, fadedOut
    anchorFrame.fadeIn = anchorFrame:CreateAnimationGroup()
    anchorFrame.fadeIn.alpha = Cell.Polyfill.CreateAnimation(anchorFrame.fadeIn, "alpha")
    Cell.Polyfill.SetFromAlpha(anchorFrame.fadeIn.alpha, 0)
    Cell.Polyfill.SetToAlpha(anchorFrame.fadeIn.alpha, 1)
    anchorFrame.fadeIn.alpha:SetDuration(0.5)
    anchorFrame.fadeIn.alpha:SetSmoothing("OUT")
    anchorFrame.fadeIn:SetScript("OnPlay", function()
        anchorFrame.fadeOut:Finish()
        fadingIn = true
    end)
    anchorFrame.fadeIn:SetScript("OnFinished", function()
        fadingIn = false
        fadingOut = false
        fadedIn = true
        fadedOut = false
        anchorFrame:SetAlpha(1)

        if CellDB["general"]["fadeOut"] and not hoverFrame:IsMouseOver() then
            anchorFrame.fadeOut:Play()
        end
    end)

    anchorFrame.fadeOut = anchorFrame:CreateAnimationGroup()
    anchorFrame.fadeOut.alpha = Cell.Polyfill.CreateAnimation(anchorFrame.fadeOut, "alpha")
    Cell.Polyfill.SetFromAlpha(anchorFrame.fadeOut.alpha, 1)
    Cell.Polyfill.SetToAlpha(anchorFrame.fadeOut.alpha, 0)
    anchorFrame.fadeOut.alpha:SetDuration(0.5)
    anchorFrame.fadeOut.alpha:SetSmoothing("OUT")
    anchorFrame.fadeOut:SetScript("OnPlay", function()
        anchorFrame.fadeIn:Finish()
        fadingOut = true
    end)
    anchorFrame.fadeOut:SetScript("OnFinished", function()
        fadingIn = false
        fadingOut = false
        fadedIn = false
        fadedOut = true
        anchorFrame:SetAlpha(0)

        if hoverFrame:IsMouseOver() then
            anchorFrame.fadeIn:Play()
        end
    end)

    hoverFrame:SetScript("OnEnter", function()
        if not CellDB["general"]["fadeOut"] then return end
        if not (fadingIn or fadedIn) then
            anchorFrame.fadeIn:Play()
        end
    end)
    hoverFrame:SetScript("OnLeave", function()
        if not CellDB["general"]["fadeOut"] then return end
        if hoverFrame:IsMouseOver() then return end
        if not (fadingOut or fadedOut) then
            anchorFrame.fadeOut:Play()
        end
    end)
end

-----------------------------------------
-- blink
-----------------------------------------
function A.CreateBlinkAnimation(region, duration, enableShowHideHook)
    local blink = region:CreateAnimationGroup()
    region.blink = blink

    local alpha = Cell.Polyfill.CreateAnimation(blink, "Alpha")
    blink.alpha = alpha
    Cell.Polyfill.SetFromAlpha(alpha, 0.25)
    Cell.Polyfill.SetToAlpha(alpha, 1)
    alpha:SetDuration(duration or 0.5)

    blink:SetLooping("BOUNCE")

    if enableShowHideHook then
        Cell.Polyfill.HookScript(region, "OnShow", function()
            blink:Play()
        end)
        Cell.Polyfill.HookScript(region, "OnHide", function()
            blink:Stop()
        end)
    else
        blink:Play()
    end
end