import bb.cascades 1.4
import basket.helpers 1.0 //KS inserted 

Page {
    id: root
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarVisibility: ChromeVisibility.Compact
    
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLocaleOrLanguageChanged
    }
    
    ScrollView {
        scrollRole: ScrollRole.Default //KS changed, old value: Main
        scrollViewProperties.scrollMode: ScrollMode.Vertical
                
        Container {
            layout: DockLayout {}
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                Header {
                    title: qsTr("Theme") + Retranslate.onLocaleOrLanguageChanged
                }
                
                Container {
                    layout: DockLayout {}
                    topPadding: ui.du(2)
                    bottomPadding: ui.du(2.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        text: qsTr("Dark theme") + Retranslate.onLocaleOrLanguageChanged
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Left
                    }
                    
                    ToggleButton {
                        id: themeToggle
                        horizontalAlignment: HorizontalAlignment.Right
                        
                        onCheckedChanged: {
                            if (checked) {
                                Application.themeSupport.setVisualStyle(VisualStyle.Dark);
                                _appConfig.set("theme", "DARK");
                            } else {
                                Application.themeSupport.setVisualStyle(VisualStyle.Bright);
                                _appConfig.set("theme", "BRIGHT");
                            }
                        }
                    }
                }
                
                Header {//KS inserted
                    title: qsTr("Brand colors") + Retranslate.onLocaleOrLanguageChanged
                }
                
                Container {
                    
                    topPadding: ui.du(2)
                    bottomPadding: ui.du(2.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    horizontalAlignment: HorizontalAlignment.Fill
                    DropDown {
                        id: primaryDropDown
                        title: "Primary color"
                        
                        Option {text: "Blue"; value: 0}
                        Option {text: "Red"; value: 1}
                        Option {text: "Green"; value: 2}
                        Option {text: "Yellow"; value: 3}
                        
                        onSelectedOptionChanged: {
                            Application.themeSupport.setPrimaryColor(calcPrimaryColor(selectedValue), calcPrimaryBaseColor(selectedValue));
                            _appConfig.set("color", selectedValue);
                        }
                    }
                }
                
                Header {
                    title: qsTr("Behavior") + Retranslate.onLocaleOrLanguageChanged
                }
                
                Container {
                    layout: DockLayout {}
                    topPadding: ui.du(2)
                    bottomPadding: ui.du(0.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        text: qsTr("Don't ask before deleting") + Retranslate.onLocaleOrLanguageChanged
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Left
                    }
                    
                    ToggleButton {
                        id: dontAskBeforeDeletingToggle
                        horizontalAlignment: HorizontalAlignment.Right
                        
                        onCheckedChanged: {
                            if (checked) {
                                _appConfig.set("do_not_ask_before_deleting", "true");
                            } else {
                                _appConfig.set("do_not_ask_before_deleting", "false");
                            }
                        }
                    }
                }
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    topPadding: ui.du(2.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    bottomPadding: ui.du(2.5)
                    DropDown {
                        title: qsTr("Date/time format") + Retranslate.onLocaleOrLanguageChanged
                        
                        options: [
                            Option {
                                id: customFormatOption
                                text: "d MMM yyyy, h:mm"
                                value: "d MMM yyyy, h:mm"
                            },
                            
                            Option {
                                id: localizedFormatOption
                                text: qsTr("Localized") + Retranslate.onLocaleOrLanguageChanged
                                value: "localized"
                            }
                        ]
                        
                        onSelectedOptionChanged: {
                            _appConfig.set("date_format", selectedOption.value);
                        }
                    }
                }
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    topPadding: ui.du(2.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    bottomPadding: ui.du(2.5)
                    DropDown {
                        id: pageSizeDropdown
                        title: qsTr("Amount of items per request") + Retranslate.onLocaleOrLanguageChanged
                        
                        onSelectedOptionChanged: {
                            _appConfig.set("amount_per_request", selectedOption.value);
                        }
                    }
                }
                
                Container {
                    layout: DockLayout {}
                    topPadding: ui.du(2)
                    bottomPadding: ui.du(0.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        text: qsTr("Clear all grid views/descending sort orders") + Retranslate.onLocaleOrLanguageChanged
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Left
                    }
                    
                    Button {//KS: Delete all stored grid view paths
                        id: deleteGridViews
                        horizontalAlignment: HorizontalAlignment.Right
                        preferredWidth: ui.du(1)
                        text: "Clear"
                        imageSource: "asset:///images/ic_delete.png"
                        color: Color.create("#ff0000")
                        onClicked: {
                            _appConfig.set("view",[""]);
                            _appConfig.set("sorting",[""]);
                            resetColor();
                            deleteTimer.start();
                        }
                    }
                }
                
                Container {//KS: not yet implemented
                    layout: DockLayout {}
                    topPadding: ui.du(2)
                    bottomPadding: ui.du(2.5)
                    leftPadding: ui.du(2.5)
                    rightPadding: ui.du(2.5)
                    horizontalAlignment: HorizontalAlignment.Fill
                    Label {
                        text: qsTr("Download on SD card") + Retranslate.onLocaleOrLanguageChanged
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Left
                    }
                    
                    ToggleButton {
                        id: saveOn
                        horizontalAlignment: HorizontalAlignment.Right
                        checked: true
                        onCheckedChanged: {
                            if (checked) {
                                //_appConfig.set("download", "SD card"); //KS: not yet implemented
                            } else {
                                //_appConfig.set("download", "flash"); //KS: not yet implemented
                            }
                        }
                    }
                }
            }
        }
    }
    
    attachedObjects: [
        Timer {
            id: deleteTimer
            
            interval: 500
            singleShot: true    
            
            onTimeout: {
                deleteGridViews.color = Color.create("#ff0000");
            }
        }//KS: end of insertion
    ]
    
    function adjustTheme() {
        var theme = _appConfig.get("theme");
        themeToggle.checked = theme && theme === "DARK";
    }
    
    function calcPrimaryColor() {//KS inserted
        var val = primaryDropDown.selectedValue;
        if (val === 0) {
            return Color.create("#0092CC");
        } else if (val === 1){
            return Color.create("#CC3333");
        } else if (val === 2){
            return Color.create("#779933");
        } else {
            return Color.create("#DCD427");
        }
    }
    
    function calcPrimaryBaseColor() {//KS inserted
        var val = primaryDropDown.selectedValue;
        if (val === 0) {
            return Color.create("#087099");
        } else if (val === 1){
            return Color.create("#FF3333");
        } else if (val === 2){
            return Color.create("#5C7829");
        } else {
            return Color.create("#B7B327");
        }
    }
    
       
    function adjustAskBeforeDeleting() {
        var doNotAsk = _appConfig.get("do_not_ask_before_deleting");
        dontAskBeforeDeletingToggle.checked = doNotAsk && doNotAsk === "true";
    }
    
    function adjustDateTimeFormat() {
        var df = _appConfig.get("date_format");
        customFormatOption.selected = (df === "" || df === customFormatOption.value);
        localizedFormatOption.selected = (df === localizedFormatOption.value);
    }
       
    onCreationCompleted: {
        adjustTheme();
        adjustAskBeforeDeleting();
        adjustDateTimeFormat();
        _app.initPageSizes(pageSizeDropdown);
    }
}