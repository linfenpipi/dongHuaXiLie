/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import QuartzCore

//
// Util delay function
//
func delay(seconds seconds: Double, completion:()->()) {
  let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
  
  dispatch_after(popTime, dispatch_get_main_queue()) {
    completion()
  }
}

enum AnimationDirection: Int {
    case Positive = 1
    case Negative = -1
}

class ViewController: UIViewController {
  
  @IBOutlet var bgImageView: UIImageView!
  
  @IBOutlet var summaryIcon: UIImageView!
  @IBOutlet var summary: UILabel!
  
  @IBOutlet var flightNr: UILabel!
  @IBOutlet var gateNr: UILabel!
  @IBOutlet var departingFrom: UILabel!
  @IBOutlet var arrivingTo: UILabel!
  @IBOutlet var planeImage: UIImageView!
  
  @IBOutlet var flightStatus: UILabel!
  @IBOutlet var statusBanner: UIImageView!
  
  var snowView: SnowView!
  
  //MARK: view controller methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //adjust ui
    summary.addSubview(summaryIcon)
    summaryIcon.center.y = summary.frame.size.height/2
    
    //add the snow effect layer
    snowView = SnowView(frame: CGRect(x: -150, y:-100, width: 300, height: 50))
    let snowClipView = UIView(frame: CGRectOffset(view.frame, 0, 50))
    snowClipView.clipsToBounds = true
    snowClipView.addSubview(snowView)
    view.addSubview(snowClipView)
    
    //start rotating the flights
    changeFlightDataTo(londonToParis)
  }
  
  //MARK: custom methods
    func fadeImageView(imageView: UIImageView, toImage: UIImage, showEffects: Bool) {
        
        UIView.transitionWithView(imageView, duration: 1.0,
            options: .TransitionCrossDissolve, animations: {
                imageView.image = toImage//通过变形动画改编image属性
            }, completion: nil)
        
        UIView.animateWithDuration(1.0, delay: 0.0,
            options: .CurveEaseOut, animations: {
                self.snowView.alpha = showEffects ? 1.0 : 0.0
            }, completion: nil)
    }
    
    func cubeTransition(label label: UILabel, text: String, direction: AnimationDirection){
        let auxlabel = UILabel(frame: label.frame)
        auxlabel.text = text
        auxlabel.font = label.font
        auxlabel.textAlignment = label.textAlignment
        auxlabel.textColor = label.textColor
        auxlabel.backgroundColor = label.backgroundColor
        
        //让auxlabel在动画前比原始laabel要小，并且要放置在合适的位置上（通过偏移量定位auxlabel）
        let auxLabelOffset = CGFloat(direction.rawValue) *
            label.frame.size.height/2.0
        
        
        auxlabel.transform = CGAffineTransformConcat(
            CGAffineTransformMakeScale(1.0, 0.1),
            CGAffineTransformMakeTranslation(0.0, auxLabelOffset))
        
        label.superview!.addSubview(auxlabel)
        
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
            auxlabel.transform = CGAffineTransformIdentity//让辅助label变成原label的大小
            label.transform = CGAffineTransformConcat(
                CGAffineTransformMakeScale(1.0, 0.1),
                CGAffineTransformMakeTranslation(0.0, -auxLabelOffset))//让原label变成辅助label的镜像
            }, completion: {_ in
                label.text = auxlabel.text
                label.transform = CGAffineTransformIdentity//原label编程原大小
                
                auxlabel.removeFromSuperview()
        })
    }
    
    func moveLabel(label: UILabel, text: String, offset: CGPoint) {
        
        let auxLabel = UILabel(frame: label.frame)
        auxLabel.text = text
        auxLabel.font = label.font
        auxLabel.textAlignment = label.textAlignment
        auxLabel.textColor = label.textColor
        auxLabel.backgroundColor = UIColor.clearColor()
        
        auxLabel.transform = CGAffineTransformMakeTranslation(offset.x, offset.y)
        auxLabel.alpha = 0
        view.addSubview(auxLabel)
        
        UIView.animateWithDuration(0.5, delay: 0.0,
                                   options: .CurveEaseIn, animations: {
                                    label.transform = CGAffineTransformMakeTranslation(
                                        offset.x, offset.y)
                                    label.alpha = 0.0
            }, completion: nil)
        UIView.animateWithDuration(0.25, delay: 0.1,
                                   options: .CurveEaseIn, animations: {
                                    auxLabel.transform = CGAffineTransformIdentity
                                    auxLabel.alpha = 1.0
                                    
            }, completion: {_ in
                //clean up
                auxLabel.removeFromSuperview()
                
                label.text = text
                label.alpha = 1.0
                label.transform = CGAffineTransformIdentity
        })
    }
    
    //用于切换不同航班显示的数据
    func changeFlightDataTo(data : FlightData , animated : Bool = false) -> () {
        if animated {
            fadeImageView(bgImageView, toImage: UIImage(named: data.weatherImageName)!, showEffects: data.showWeatherEffects)
            let direction: AnimationDirection = data.isTakingOff ? .Positive : .Negative
            cubeTransition(label: flightNr, text: data.flightNr, direction: direction)
            cubeTransition(label: gateNr, text: data.gateNr, direction: direction)
            let offsetDeparting = CGPoint(
                x: CGFloat(direction.rawValue * 80),
                y: 0.0)
            moveLabel(departingFrom, text: data.departingFrom,
                      offset: offsetDeparting)
            
            let offsetArriving = CGPoint(
                x: 0.0,
                y: CGFloat(direction.rawValue * 50))
            moveLabel(arrivingTo, text: data.arrivingTo,
                      offset: offsetArriving)

        }else {
            bgImageView.image = UIImage(named: data.weatherImageName)
            snowView.hidden = !data.showWeatherEffects
            flightNr.text = data.flightNr
            gateNr.text = data.gateNr
            departingFrom.text = data.departingFrom
            arrivingTo.text = data.arrivingTo;
            flightStatus.text = data.flightStatus;
        }
        summary.text = data.summary
        
        
        delay(seconds: 3.0) { 
            self.changeFlightDataTo(data.isTakingOff ? parisToRome : londonToParis ,animated: true)
        }
    }
  
  
}
