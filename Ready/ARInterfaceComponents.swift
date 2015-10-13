//
//  ARInterfaceComponents.swift
//  Ready
//
//  Created by Alexander Rhett Crammer on 10/11/15.
//  Copyright © 2015 HoA. All rights reserved.
//

import UIKit

extension Int {
    var degreesToRadians: CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 360.0
    }
}

class ARBottomLineField: UITextField {
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Bottom Border
        let textFieldBottomBorder = CALayer()
        let borderWidth: CGFloat = 1.5
        textFieldBottomBorder.borderColor = self.textColor!.CGColor
        textFieldBottomBorder.frame = CGRectMake(0 - borderWidth, 0 - borderWidth, self.frame.size.width + borderWidth * 100, self.frame.size.height)
        textFieldBottomBorder.borderWidth = borderWidth
        self.layer.addSublayer(textFieldBottomBorder)
        self.layer.masksToBounds = true
        
        // Left Padding
        let padding: CGFloat = 15
        self.leftView = UIView(frame: CGRectMake(0, 0, padding, self.frame.size.height))
        self.leftViewMode = UITextFieldViewMode.Always
    }
}

class ARButton: UIButton {
    var idleColour: UIColor? = UIColor.lightGrayColor()
    var tapColour: UIColor? = UIColor.grayColor()
    
    required init!(coder: NSCoder) {
        super.init(coder: coder)
        
        // Remember the Buttons' Title Colour for the Border
        self.idleColour = self.titleColorForState(UIControlState.Normal)
        
        // Draw Border
        self.layer.cornerRadius = 17.5
        self.layer.borderWidth = 1.5
        self.layer.borderColor = self.idleColour?.CGColor
        
        self.adjustsImageWhenHighlighted = false
        
        // Change the Border When Tapped
        addTarget(self, action: "drawIdleBorder", forControlEvents: UIControlEvents.TouchUpInside)
        addTarget(self, action: "drawIdleBorder", forControlEvents: UIControlEvents.TouchUpOutside)
        addTarget(self, action: "drawActiveBorder", forControlEvents: UIControlEvents.TouchDown)
    }
    
    func drawIdleBorder() {
        // Animate the Background and Border Colour Changes
        gentlyChangeColours(false)
    }
    
    func drawActiveBorder() {
        // Update the Text Colour
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        
        // Animate the Background and Border Colour Changes
        gentlyChangeColours(true)
    }
    
    func gentlyChangeColours(pressed: Bool = true) {
        if pressed {
            // The Button is Pressed; Gently Change the Border and Background Colours
            
            // Store the Current Background and Border Colours for Manipulation Later
            var oldBackgroundHue: CGFloat = 0.0,
            oldBackgroundSaturation: CGFloat = 0.0,
            oldBackgroundBrightness: CGFloat = 0.0,
            oldBackgroundAlpha: CGFloat = 0.0
            self.tapColour!.getHue(&oldBackgroundHue,
                saturation: &oldBackgroundSaturation,
                brightness: &oldBackgroundBrightness,
                alpha: &oldBackgroundAlpha)
            
            UIView.animateWithDuration(0.15, animations: {
                () -> Void in
                
                // Update the Border Colour
                self.layer.borderColor = UIColor(hue: oldBackgroundHue,
                    saturation: oldBackgroundSaturation,
                    brightness: oldBackgroundBrightness - (50/255),
                    alpha: oldBackgroundAlpha).CGColor
                
                UIView.animateWithDuration(0.25, animations: {
                    () -> Void in
                    
                    // Update the Background Color
                    self.backgroundColor = self.tapColour!
                })
            })
        } else {
            // The Button was Released; Gently Restore the (Assumed) Transparency
            
            UIView.animateWithDuration(0.25, animations: {
                () -> Void in
                
                // Update the Border Colour
                self.layer.borderColor = self.idleColour?.CGColor
                
                UIView.animateWithDuration(3.55, animations: {
                    () -> Void in
                    
                    // Update the Background Color
                    self.backgroundColor = UIColor(white: 1, alpha: 0)
                })
            })
        }
    }
}

class ARPancakeButton: UIControl {
    let top = CALayer(),
    middle = CALayer(),
    bottom = CALayer()
    var menuVisible: Bool? = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override required init(frame: CGRect) {
        super.init(frame: frame)
        
        let bar = CGRectMake(-22.5, 0, 45, 5)
        self.top.frame = bar
        self.middle.frame = bar
        self.middle.position.y += 15
        self.bottom.frame = bar
        self.bottom.position.y += 30
        
        self.top.anchorPoint.x = 0.0
        self.top.anchorPoint.y = 0.75
        self.middle.anchorPoint.x = 0.0
        self.middle.anchorPoint.y = 0.5
        self.bottom.anchorPoint.x = 0.0
        self.bottom.anchorPoint.y = 0.25
        
        self.top.backgroundColor = UIColor.darkGrayColor().CGColor
        self.middle.backgroundColor = UIColor.darkGrayColor().CGColor
        self.bottom.backgroundColor = UIColor.darkGrayColor().CGColor
        self.layer.addSublayer(self.top)
        self.layer.addSublayer(self.middle)
        self.layer.addSublayer(self.bottom)
        
        addTarget(self, action: "fold", forControlEvents: UIControlEvents.TouchDown)
    }
    
    func fold() {
        if self.menuVisible == false {
            // Fold the Bars
            self.top.transform = CATransform3DRotate(self.top.transform, -90.degreesToRadians, 0.0, 0.0, -1.0)
            self.bottom.transform = CATransform3DRotate(self.bottom.transform, 90.degreesToRadians, 0.0, 0.0, -1.0)
            
            UIView.animateWithDuration(0.05, animations: {
                () -> Void in
                
                // Move the Bars Over
                self.top.position.x += 6.5
                self.bottom.position.x += 6.5
                
                // Fade the Middle Bar
                self.middle.backgroundColor = UIColor(white: 1, alpha: 0).CGColor
            })
            
            self.menuVisible = true
        } else {
            // Unfold the Bars
            self.top.transform = CATransform3DRotate(self.top.transform, -90.degreesToRadians, 0.0, 0.0, 1.0)
            self.bottom.transform = CATransform3DRotate(self.bottom.transform, 90.degreesToRadians, 0.0, 0.0, 1.0)
            
            UIView.animateWithDuration(0.05, animations: {
                () -> Void in
                
                // Move the Bars Over
                self.top.position.x -= 6.5
                self.bottom.position.x -= 6.5
                
                // Fade the Middle Bar
                self.middle.backgroundColor = UIColor.darkGrayColor().CGColor
            })
            
            self.menuVisible = false
        }
    }
}
