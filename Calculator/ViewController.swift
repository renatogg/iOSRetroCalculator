//
//  ViewController.swift
//  8bit Calculator
//
//  Created by Renato Gasoto on 1/11/16.
//  Copyright © 2016 Renato Gasoto. All rights reserved.
//

import UIKit
import AVFoundation

extension UILabel {
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        font = fontToFitHeight()
    }
    
    // Returns an UIFont that fits the new label's height.
    private func fontToFitHeight() -> UIFont {
        
        var minFontSize: CGFloat = 10 // CGFloat 18
        var maxFontSize: CGFloat = 67     // CGFloat 67
        var fontSizeAverage: CGFloat = 0
        var textAndLabelHeightDiff: CGFloat = 0
        
        while (minFontSize <= maxFontSize) {
            fontSizeAverage = minFontSize + (maxFontSize - minFontSize) / 2
            
            if let labelText: NSString = text {
                let labelHeight = frame.size.height
                
                let testStringHeight = labelText.sizeWithAttributes(
                    [NSFontAttributeName: font.fontWithSize(fontSizeAverage)]
                    ).height
                
                textAndLabelHeightDiff = labelHeight - testStringHeight
                
                if (fontSizeAverage == minFontSize || fontSizeAverage == maxFontSize) {
                    if (textAndLabelHeightDiff < 0) {
                        return font.fontWithSize(fontSizeAverage - 1)
                    }
                    return font.fontWithSize(fontSizeAverage)
                }
                
                if (textAndLabelHeightDiff < 0) {
                    maxFontSize = fontSizeAverage - 1
                    
                } else if (textAndLabelHeightDiff > 0) {
                    minFontSize = fontSizeAverage + 1
                    
                } else {
                    return font.fontWithSize(fontSizeAverage)
                }
            }
        }
        return font.fontWithSize(fontSizeAverage)
    }
}
    


class ViewController: UIViewController {
    var runningNumber = ""
    var prevRunningNumber = ""
    var value1 = ""
    var value2 = ""
    var btnSound: AVAudioPlayer!
    var clear = true
    
    
//    var operation: MathOperator = .empty
    var operation: MathOperator = .empty
    
    @IBOutlet weak var lblOutput: UILabel!
    override func viewDidLoad() {
        lblOutput.adjustsFontSizeToFitWidth=true
        super.viewDidLoad()
        let soundPath = NSBundle.mainBundle().pathForResource("btn", ofType: "wav")
        let soundURL = NSURL(fileURLWithPath: soundPath!)
        do{
            try btnSound = AVAudioPlayer(contentsOfURL: soundURL)
        } catch let err as NSError{
            print ("Sound not loaded: \(err.debugDescription)")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func numberTyped(sender: UIButton){
        if clear{
            operation = .empty
            prevRunningNumber = ""
            value1 = ""
            value2 = ""
            clear = false
            print("clear")
        }
        
        let temp = runningNumber + "\(sender.tag)"
        if temp.characters.count <= 20 {
            if  temp.characters.count <= 2 {
                lblOutput.text = String(Int64(temp)!)
            }
            else {
                lblOutput.text = temp
            }
            
            runningNumber = lblOutput.text!
        }
    }
    
    func operate(operation :MathOperator)->Double{
        if value1 == ""{
            value1 = "0"
        }
        if value2 == ""{
            value2 = "0"
        }
        let v1 = Double(value1)!
        let v2 = Double(value2)!
        switch operation{
            case .sum:
                return v1+v2
            case .sub:
                return v1-v2
            case .mult:
                return v1*v2
            case .div:
                return v1/v2
            default:
                return operate(self.operation)
        }
    }
    @IBAction func playSound(sender: AnyObject){
        if btnSound.playing{
            btnSound.stop()
        }
        btnSound.play()
    }
    @IBAction func operatorPressed(sender: AnyObject) {
        let operation = MathOperator(rawValue: sender.tag)!
        if self.operation == .empty || (clear && operation != .equal){
            if !clear{
                value1 =             runningNumber
            }
            clear = false
            runningNumber = ""
            if(operation != .equal){
                self.operation = operation
            }
        }else{
            if runningNumber == ""{
                    runningNumber = prevRunningNumber
            }
            if runningNumber != ""{
                value2 = runningNumber
                prevRunningNumber = runningNumber
                runningNumber = ""

                if operation != .equal{
                    self.operation = operation
                    
                }else{
                    clear = true
                }
                value1 = String(operate(operation))

                lblOutput.text = value1
            }
            
            
            
        }
    }

}

enum MathOperator: Int{
    case empty = -1
    case sum = 0
    case sub = 1
    case div = 2
    case mult = 3
    case equal = 4
    
}


