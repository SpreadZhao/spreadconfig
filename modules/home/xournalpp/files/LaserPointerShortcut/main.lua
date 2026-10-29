function initUi()
    app.registerUi({
        menu = "Laser pointer",
        callback = "selectLaserPointer",
        accelerator = "XF86Tools",
    })
end

function selectLaserPointer()
    app.changeActionState("select-tool", app.C.Tool_laserPointerPen)
end
