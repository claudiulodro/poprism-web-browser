''
' Style the non-custom screens
''
function styleMenus() as void
    app = CreateObject("roAppManager")

    primaryText                 = "#h8A8A5C"
    secondaryText               = "#h8A8A5C"
    backgroundColor             = "#ffffff"
    
    theme = {
        BackgroundColor: backgroundColor
        OverhangSliceHD: "pkg:/images/overhang.png"
        OverhangSliceSD: "pkg:/images/overhang.png"
        OverhangLogoHD: "pkg:/images/navLogo.png"
        OverhangLogoSD: "pkg:/images/navLogo.png"
        OverhangOffsetSD_X: "75"
        OverhangOffsetSD_Y: "15"
        OverhangOffsetHD_X: "75"
        OverhangOffsetHD_Y: "15"
        BreadcrumbTextLeft: primaryText
        BreadcrumbTextRight: primaryText
        BreadcrumbDelimiter: primaryText
        ListItemText: secondaryText
        ListItemHighlightText: primaryText
        ListScreenDescriptionText: secondaryText
        ListItemHighlightHD: "pkg:/images/select_bkgnd.png"
        ListItemHighlightSD: "pkg:/images/select_bkgnd.png"        
    }
    app.SetTheme( theme )
end function
