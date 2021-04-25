//
//  DailyViewController.swift
//  asas2
//
//  Created by saj panchal on 2020-04-05.
//  Copyright © 2020 saj panchal. All rights reserved.
//

import UIKit

class DailyViewController: UIViewController {
    var cityString = String()
    var weatherString = String()
    var dateString = String()
    var tempString = String()
    var sunriseInt = UInt()
    var sunsetInt = UInt()
    var humidityInt = Int()
    var windDouble = Double()
    var feelsLikeDouble = Double()
    var pressureInt = Int()
    var weatherImgString = String()
    let dateformater = DateFormatter()
    var tempUnitSymbol = String()
    var speedUnitSymbol = String()
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var backGroundImage: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBAction func TempSegmentCtrl(_ sender: Any) {
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        displayData()
        
    }
    
    func displayData() -> Void
    {
        dateLabel.text = dateString
        cityLabel.text = cityString
        weatherLabel.text = weatherString
        tempLabel.text = tempString + tempUnitSymbol
        let sunriseTime = Date(timeIntervalSince1970: TimeInterval(sunriseInt))
        dateformater.dateFormat = "hh:mm"
        let sunriseTimeString = dateformater.string(from: sunriseTime)
        sunriseLabel.text = String(sunriseTimeString) + " AM"
        let sunsetTime = Date(timeIntervalSince1970: TimeInterval(sunsetInt))
        let sunsetTimeString = dateformater.string(from: sunsetTime)
        sunsetLabel.text = String(sunsetTimeString)  + " PM"
        humidityLabel.text = String(humidityInt) + "%"
        windSpeedLabel.text = String(format:"%.2f", windDouble) + " " + speedUnitSymbol
        feelsLikeLabel.text = String(feelsLikeDouble) + tempUnitSymbol
        pressureLabel.text = String(pressureInt) + " hPa"
        weatherImage.image = UIImage(named: weatherImgString + ".png")
        setBackgroundImage()
    }
    func setBackgroundImage()->Void
    {
        switch weatherImgString {
        case "01d":
            backGroundImage.image = UIImage(named: "sunny.jpg")
        case "01n":
            backGroundImage.image = UIImage(named: "sunny.jpg")
        case "02d","03d","04d":
            backGroundImage.image = UIImage(named: "cloudy.jpg")
        case "02n","03n","04n":
            backGroundImage.image = UIImage(named: "cloudy.jpg")
        case "09d","10d":
            backGroundImage.image = UIImage(named: "rainy.jpg")
        case "09n","10n":
            backGroundImage.image = UIImage(named: "rainy.jpg")
        case "11d":
            backGroundImage.image = UIImage(named: "thunderstorm.jpg")
        case "11n":
            backGroundImage.image = UIImage(named: "thunderstorm.jpg")
        case "13d":
            backGroundImage.image = UIImage(named: "snow.png")
        case "13n":
            backGroundImage.image = UIImage(named: "snow.png")
        case "50d":
            backGroundImage.image = UIImage(named: "rainy.jpg")
        case "50n":
            backGroundImage.image = UIImage(named: "rainy.jpg")
        default:
            print("No Image found")
        }
    }
    

}
