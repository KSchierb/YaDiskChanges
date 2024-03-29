import bb.cascades 1.4

CustomListItem {
    id: root
    
    property string name: "sdfsdf"
    property string value: "sdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdf sdfsdfsdfsdf"
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        leftPadding: ui.du(1)
        topPadding: ui.du(1)
        rightPadding: ui.du(1)
        bottomPadding: ui.du(1)
        
        Label {
            text: root.name
            textStyle.base: SystemDefaults.TextStyles.SubtitleText //KS .Text
            textStyle.fontWeight: FontWeight.W400 //KS W100
        }
        
        Container {
            Label {
                text: root.value
                textStyle.base: SystemDefaults.TextStyles.PrimaryText //KS
                textStyle.fontWeight: FontWeight.W400 //KS
                multiline: true
            }
        }
    }
}
