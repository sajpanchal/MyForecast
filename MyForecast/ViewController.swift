//
//  ViewController.swift
//  asas2
//
//  Created by saj panchal on 2020-04-08.
//  Copyright © 2020 saj panchal. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate {
    let lm = CLLocationManager()
    var userDefault = UserDefaults.standard
    var currentLatitude : Double?
    var currentLongitude : Double?
    var modifiedDate : [String] = []
    var weatherCondition : [String] = []
    var currentTemp : [String] = []
    var currUnixDate : UInt64 = 0
    var prevUnixDate : UInt64 = 0
    var dayIndex : Int = 0
    var difference : UInt64 = 0
    var weatherImgString: [String] = []
    var listIndex = 0
    var weatherDataCounts : Int?
    var cityString : [String] = []
    var weatherName : [String] = []
    var feelsLikeTemp : [Double] = []
    var sunriseInt : [UInt] = []
    var sunsetInt : [UInt] = []
    var humidityInt : [Int] = []
    var windDouble : [Double] = []
    var pressureInt : [Int] = []
    var dt : [UInt64] = []
    let dailyViewSegueIdentifier = "DailyViewSegue"
    var date1 : Date?
    var dateFormatter = DateFormatter()
    var scaleUnit : String = "metric"
    var tempUnitSymbol : String = " °C"
    var speedUnitSymbol : String = "km/h"
    var speedCnvtMuliplier : Double = 3.6
    var documentDirectoryUrl : URL?
    var home : URL?
    var activityView = UIActivityIndicatorView(style: .large)
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tempSegment: UISegmentedControl!
    
    
    struct JSonWeatherData: Codable
    {
        let list: [List]
        let city : City
        let cnt: Int
    }
    struct City : Codable
    {
        let name : String
        let sunrise: UInt
        let sunset: UInt
    }
    struct List: Codable
    {
        let dt : UInt64
        let dt_txt : String
        let main : Main
        let weather : [Weather]
        let wind : Wind
    }
    struct Main: Codable
    {
        let temp : Double
        let feels_like : Double
        let pressure : Int
        let humidity : Int
    }
    struct Wind: Codable
    {
        let speed: Double
    }
    struct Weather: Codable
    {
        let description : String
        let icon : String
        let main : String
    }
     
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityView.center = self.view.center
        
        self.view.addSubview(activityView)
        NSLog("the view: %@", self.view)
        print("heelo")
        home = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        documentDirectoryUrl = home?.appendingPathComponent("myData.plist")
        
        tableView.dataSource = self
        tableView.rowHeight = 90
        resetAppData()
        lm.delegate = self
        lm.requestWhenInUseAuthorization()
        lm.startUpdatingLocation()
        dateFormatter.dateFormat = "E, MMM d, yyyy"
    }
    
    @IBAction func tempSegmentCntl(_ sender: Any)
    {
        self.activityView.startAnimating()
        if tempSegment.selectedSegmentIndex == 0
        {
            
                
                self.scaleUnit = "metric"
                self.tempUnitSymbol = "°C"
                self.speedUnitSymbol = "km/h"
                self.speedCnvtMuliplier = 3.6
                
            
        }
        else if tempSegment.selectedSegmentIndex == 1
        {
           
                
                self.scaleUnit = "imperial"
                self.tempUnitSymbol = "°F"
                self.speedUnitSymbol = "mph"
                self.speedCnvtMuliplier = 1
              
            
        }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        
        self.resetAppData()
      
        
    }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
            self.decodeJsonScript()
            self.activityView.stopAnimating()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.last
        {
            currentLatitude = location.coordinate.latitude
            currentLongitude = location.coordinate.longitude
        }
        else
        {
            print("location not found!")
        }
        decodeJsonScript()
    }
    
    func decodeJsonScript() -> Void
    {
        if(currentLatitude != nil && currentLongitude != nil)
        {
            /* Step 1: set URL to call API */
            let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(currentLatitude!)&lon=\(currentLongitude!)&appid=1b60117972a076022caad8a5c23bb464&units=\(scaleUnit)"
            /* Step 2: Create URL session */
            let urlSession = URLSession(configuration: .default)
            let url = URL(string: urlString)
            var readableData : JSonWeatherData?
            
            if let url = url
            {
                /* Step 3: give URL session a data task */
                let dataTask = urlSession.dataTask(with: url)
                {
                    (data, response, error) in
                    if let error = error
                    {
                            print("Error code :\n",error)
                           // readableData = self.loadData()
                            readableData = self.readData()
                            self.filterDailyWeatherData(readableData!)
                    }
                    else if let data = data
                    {
                        let jsonDecode = JSONDecoder()
                        do
                        {
                            readableData = try jsonDecode.decode(JSonWeatherData.self, from: data)
                           // self.saveData(readableData!)
                            self.writeData(readableData!)
                            self.filterDailyWeatherData(readableData!)
                        }
                        catch
                        {
                            print("Latest data is not available. Loading last saved data....")
                           // readableData = self.loadData()
                            readableData = self.readData()
                            self.filterDailyWeatherData(readableData!)
                        }
                    }
                }
                    dataTask.resume()
            }
            //print("userdefault:\n",readableData!)
        }
    }
    
    func saveData(_ readableData: JSonWeatherData)
    {
         /* Setting the structure data to userdefault */
        let encoder = PropertyListEncoder()
        do
        {
            let encodedData = try encoder.encode(readableData)
            self.userDefault.set(encodedData, forKey: "jsonData")
        }
        catch
        {
            print("can't encode the data.")
        }
    }
    func loadData() -> JSonWeatherData
    {
        let decoder = PropertyListDecoder()
        var myUserDefault2 : JSonWeatherData?
        do
        {
        /* Loading the encoded data from userdefault to a structure */
        let myUserDefault = self.userDefault.object(forKey: "jsonData") as? Data
        let decodedData = try decoder.decode(JSonWeatherData.self, from: myUserDefault!)
        /* Loading the decoded data from encoded structure */
        myUserDefault2 = decodedData
        }
        catch
        {
            print("Can't decode the data.")
        }
        return myUserDefault2!
    }
    
    func writeData(_ readableData: JSonWeatherData)
    {
        let encoder = PropertyListEncoder()
        do
        {
            let data = try encoder.encode(readableData)
            do
            {
                try data.write(to: documentDirectoryUrl!)
            }
            catch
            {
                print("I can't write.")
            }
        }
        catch
        {
            print("I can't decode.")
        }
    }
    func readData() -> JSonWeatherData
    {
       // let documentDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        var readableData : JSonWeatherData?
        let decoder = PropertyListDecoder()
        do
        {
            let dataRead = try Data(contentsOf: documentDirectoryUrl!)
            do
            {
                readableData = try decoder.decode(JSonWeatherData.self, from: dataRead)
            }
            catch
            {
                print("I can't decode it.")
            }
        }
        catch
        {
            print("I can't read it.")
        }
        return readableData!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dayIndex
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCell
        if !(currentTemp.isEmpty)
        {
            cell.tempLabel.text = currentTemp[indexPath.row] + tempUnitSymbol
        }
        if !(weatherCondition.isEmpty)
        {
            cell.weatherConditionLabel.text = weatherCondition[indexPath.row]
            cell.weatherImage.image = UIImage(named: (weatherImgString[indexPath.row]) + ".png")
        }
        
        if !(modifiedDate.isEmpty)
        {
            cell.dateLabel.text = modifiedDate[indexPath.row]
        }
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destination = segue.destination as! DailyViewController
        if let dayIndex = tableView.indexPathForSelectedRow?.row
        {
            destination.dateString = modifiedDate[dayIndex]
            destination.cityString = cityString[dayIndex]
            destination.weatherString = weatherName[dayIndex]
            destination.tempString = currentTemp[dayIndex]
            destination.sunriseInt = sunriseInt[dayIndex]
            destination.sunsetInt = sunsetInt[dayIndex]
            destination.humidityInt = humidityInt[dayIndex]
            destination.windDouble = windDouble[dayIndex]
            destination.feelsLikeDouble = feelsLikeTemp[dayIndex]
            destination.pressureInt = pressureInt[dayIndex]
            destination.weatherImgString = weatherImgString[dayIndex]
            destination.tempUnitSymbol = tempUnitSymbol
            destination.speedUnitSymbol = speedUnitSymbol
        }
    }
    
    func filterDailyWeatherData(_ readableData: JSonWeatherData)
    {
        
        DispatchQueue.main.async
            {
                self.weatherDataCounts = readableData.cnt
                while self.listIndex < (self.weatherDataCounts! - 1)
                {
                    self.currUnixDate = readableData.list[self.listIndex].dt
                    self.difference = self.currUnixDate - self.prevUnixDate
                    if self.difference >= 86400
                    {
                        self.updateAppWeatherData(readableData)
                    }
                    self.listIndex += 1
                }
                self.tableView.reloadData()
        }
    }
    func updateAppWeatherData(_ readableData: JSonWeatherData) -> Void
    {
        self.date1 = Date(timeIntervalSince1970: TimeInterval(readableData.list[self.listIndex].dt))
        self.modifiedDate.append(self.dateFormatter.string(from: self.date1!))
        self.prevUnixDate = self.currUnixDate
        self.weatherCondition.append(readableData.list[self.listIndex].weather[0].description)
        self.currentTemp.append(String(readableData.list[self.listIndex].main.temp))
        self.weatherImgString.append(String(readableData.list[self.listIndex].weather[0].icon))
        self.cityString.append(readableData.city.name)
        self.weatherName.append(readableData.list[self.listIndex].weather[0].main)
        self.sunriseInt.append(readableData.city.sunrise)
        self.sunsetInt.append(readableData.city.sunset)
        self.humidityInt.append(readableData.list[self.listIndex].main.humidity)
        self.windDouble.append((readableData.list[self.listIndex].wind.speed)*speedCnvtMuliplier)
        self.feelsLikeTemp.append(readableData.list[self.listIndex].main.feels_like)
        self.pressureInt.append(readableData.list[self.listIndex].main.pressure)
        self.dayIndex += 1
    }
    
    func resetAppData() -> Void
    {
        modifiedDate.removeAll()
        weatherCondition.removeAll()
        currentTemp.removeAll()
        currUnixDate = 0
        prevUnixDate = 0
        dayIndex = 0
        difference = 0
        weatherImgString.removeAll()
        listIndex = 0
        weatherDataCounts = 0
        cityString.removeAll()
        weatherName.removeAll()
        feelsLikeTemp.removeAll()
        sunriseInt.removeAll()
        sunsetInt.removeAll()
        humidityInt.removeAll()
        windDouble.removeAll()
        pressureInt.removeAll()
        dt.removeAll()
    }

    
    


}
