import bb.cascades 1.4

Container {
    id: root
    
    property string path: ""
    
    horizontalAlignment: HorizontalAlignment.Fill
    
    visible: _fileController.selectedFiles.length !== 0
    
    layout: DockLayout {}
    
    Button {
        horizontalAlignment: HorizontalAlignment.Left
        text: qsTr("Cancel") + Retranslate.onLocaleOrLanguageChanged//KS changed: clear? better cancel
        maxWidth: ui.du(25)
        margin.leftOffset: ui.du(2)
        margin.topOffset: ui.du(2)
        margin.bottomOffset: ui.du(2)
        
        onClicked: {
            _fileController.clearSelectedFiles();
        }
    }
    
    Label {
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
        text: qsTr("Selected") + Retranslate.onLocaleOrLanguageChanged + " " + (_fileController.selectedFiles.length || 0)
    }
    
    Button {
        horizontalAlignment: HorizontalAlignment.Right
        text: qsTr("Move") + Retranslate.onLocaleOrLanguageChanged
        maxWidth: ui.du(25)
        margin.topOffset: ui.du(2)
        margin.rightOffset: ui.du(2)
        margin.bottomOffset: ui.du(2)
        
        enabled: _fileController.currentPath !== root.path
        
        onClicked: {
            _fileController.selectedFiles.forEach(function(f) {
                _fileController.move(f.name, f.path, root.path, f.dir, f.ext, f.size);//KS inserted file.size
            });
            _fileController.clearSelectedFiles();
        }
    }
    
    Divider {
        verticalAlignment: VerticalAlignment.Bottom
    }
}