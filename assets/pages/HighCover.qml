import bb.cascades 1.4

Container {
    id: root
    
    property variant account: {email: "", name: {display_name: ""}}
    property string spaceUsage: ""
    property int bytesInGB: 1073741824
    
    horizontalAlignment: HorizontalAlignment.Fill
    background: Color.White
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        
        Container {
            margin.topOffset: ui.du(2)
            
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            verticalAlignment: VerticalAlignment.Center
            
            ImageView {
                imageSource: "asset:///images/ic_contact.png"
                //filterColor: ui.palette.secondaryTextOnPlain; replaced by:
                filterColor: Color.DarkGray
                verticalAlignment: VerticalAlignment.Center
                maxWidth: ui.du(5)
                maxHeight: ui.du(5)
            }
            
            Container {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                verticalAlignment: VerticalAlignment.Center
                
                Container {
                    Label {
                        id: fioLabel
                        //KS deleted:text: root.account === undefined ? "" : root.account.name.display_name
                        textStyle.base: SystemDefaults.TextStyles.SubtitleText
                        textStyle.color: Color.Black
                        multiline: true
                    }
                }
                
                Container {
                    Label {
                        id: loginLabel
                       //KS deleted: text: root.account === undefined ? "" : root.account.emailKS 
                        textStyle.base: SystemDefaults.TextStyles.SmallText
                        textStyle.color: Color.Black
                        textStyle.fontWeight: FontWeight.W300
                    }
                }
                
            }
        }
        
        Divider {}
    }
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        
        Container {
            margin.topOffset: ui.du(2)
            
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            verticalAlignment: VerticalAlignment.Center
            
            ImageView {
                imageSource: "asset:///images/ic_set_as_default.png"
                //filterColor: ui.palette.secondaryTextOnPlain, replaced by:
                filterColor: Color.DarkGray
                verticalAlignment: VerticalAlignment.Center
                maxWidth: ui.du(5)
                maxHeight: ui.du(5)
            }
            
            Container {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                verticalAlignment: VerticalAlignment.Center
                
                Container {
                    Label {
                        id: bytesLabel
                        textStyle.base: SystemDefaults.TextStyles.SubtitleText
                        multiline: true
                        textStyle.color: Color.Black
                        textStyle.fontWeight: FontWeight.W300
                        // text: "2134" KS deleted
                    }
                }
            }
        }
        
        Divider {}
    }
    
    onSpaceUsageChanged: { // KS deleted
        if (spaceUsage !== undefined) {
            bytesLabel.text = spaceUsage;
        }
    }
    
    onAccountChanged: {
        if (spaceUsage !== undefined) {
        fioLabel.text = root.account.name.display_name;
        loginLabel.text =root.account.email;
        }
    }
    
}
