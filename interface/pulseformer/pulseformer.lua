function init()
    local settings = config.getParameter("settings")
    widget.setChecked("cbxHidden", settings.hidden)
    widget.setChecked("cbxCamo", settings.camo)
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
