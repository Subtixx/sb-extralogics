local color = {
    white = {255,255,255},
    red = {255,0,0}
}

function init()
    local settings = config.getParameter("settings")
    widget.setText("tbxRange",tostring(settings.timerval))
    spnRange.current = settings.timerval
    widget.setChecked("cbxHidden", settings.hidden)
    widget.setChecked("cbxCamo", settings.camo)
end

spnRange = {
    min = 0.5,
    max = 128,
    step = 2,
    current = 0.5,

    up = function()
        spnRange.current = math.min(spnRange.current * spnRange.step, spnRange.max)
        widget.setText("tbxRange", tostring(spnRange.current))
    end,

    down = function()
        spnRange.current = math.max(spnRange.current / spnRange.step, spnRange.min)
        widget.setText("tbxRange", tostring(spnRange.current))
    end
}

function setTimerVal()
    local n = tonumber(widget.getText("tbxRange"))
    if n ~= nil and n >= spnRange.min and n <= spnRange.max then
        widget.setFontColor("tbxRange", color.white)
        spnRange.current = n
        send("timerval", n)
    else
        widget.setFontColor("tbxRange", color.red)
    end
end

function setHidden()
    send("hidden",  widget.getChecked("cbxHidden"))
end

function setCamo()
    send("camo", widget.getChecked("cbxCamo"))
end

function loadDefaults()
    local settings = root.getConfiguration("PulseFormer")
    if settings then
    send(settings)
        initGUI(settings)
    end
end

function saveDefaults()
    root.setConfiguration("PulseFormer", {
        timerval = spnRange.current,
        hidden = widget.getChecked("cbxHidden"),
        camo = widget.getChecked("cbxCamo")
    })
end

function send(dataOrKey, value)
    local data = dataOrKey
    if type(dataOrKey) ~= table then
      data = {}
      data[dataOrKey] = value
    end
    world.sendEntityMessage(pane.sourceEntity(), "setData", data)
end
