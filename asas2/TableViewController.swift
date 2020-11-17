//
//  TableViewController.swift
//  asas2
//
//  Created by saj panchal on 2020-04-04.
//  Copyright © 2020 saj panchal. All rights reserved.
//

import UIKit
import CoreLocation

class TableViewController: UITableViewController, CLLocationManagerDelegate {
    let lm = CLLocationManager()
    var currentLatitude : Double?
    var currentLongitude : Double?
    var modifiedDate : [String] = []
    var weatherCondition : [String] = []
    var currentTemp : [String] = []
    var currUnixDate : UInt64 = 0
    var prevUnixDate : UInt64 = 0
    var dayIndex : Int = 0
    var diff : UInt64 = 0
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
    @IBOutlet weak var segmentControlBtn: UISegmentedControl!
    

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
        resetAppData()
        lm.delegate = self
        lm.requestWhenInUseAuthorization()
        lm.startUpdatingLocation()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        print("dateFormat",dateFormatter.dateFormat)
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
    
    @IBAction func tempSegmentCtrl(_ sender: Any)
    {
        if segmentControlBtn.selectedSegmentIndex == 0
        {
            scaleUnit = "metric"
            tempUnitSymbol = "°C"
            speedUnitSymbol = "km/h"
            speedCnvtMuliplier = 3.6
        }
        else if segmentControlBtn.selectedSegmentIndex == 1
        {
            scaleUnit = "imperial"
            tempUnitSymbol = "°F"
            speedUnitSymbol = "mph"
            speedCnvtMuliplier = 1
        }
        resetAppData()
        decodeJsonScript()
    }
    
    func decodeJsonScript() -> Void
    {
        if(currentLatitude != nil && currentLongitude != nil)
        {
            /* Step 1: set URL to call API */
            let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(currentLatitude!)&lon=\(currentLongitude!)&appid=1b60117972a076022caad8a5c23bb464&units=\(scaleUnit)"
            print(urlString)
            /* Step 2: Create URL session */
            let urlSession = URLSession(configuration: .default)
            let url = URL(string: urlString)
            if let url = url
            {
                /* Step 3: give URL session a data task */
                let dataTask = urlSession.dataTask(with: url)
                {
                    (data, response, error) in
                    if let data = data
                    {
                        let jsonDecode = JSONDecoder()
                   
                    do
                    {
                        let readableData = try jsonDecode.decode(JSonWeatherData.self, from: data)
                        self.filterDailyWeatherData(readableData)
                    }
                    catch
                    {
                        print("I Can't decode your data")
                    }
                }
            }
                dataTask.resume()
        }
    }
}
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("index",index)
        return dayIndex
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCell
      
        if !(currentTemp.isEmpty)
        {
            cell.tempLabel.text = currentTemp[indexPath.row] + tempUnitSymbol
            print("cell called:",currentTemp[indexPath.row])
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
            self.diff = self.currUnixDate - self.prevUnixDate
            if self.diff >= 86400
            {
                self.updateAppWeatherData(readableData)
            }
            self.listIndex += 1
          }
            self.tableView.reloadData()
            print("table refreshed")
        }
    }
    func updateAppWeatherData(_ readableData: JSonWeatherData) -> Void
    {
       self.date1 = Date(timeIntervalSince1970: TimeInterval(readableData.list[self.listIndex].dt))
              self.modifiedDate.append(self.dateFormatter.string(from: self.date1!))
        print("Date:",self.dateFormatter.string(from: self.date1!))
        self.prevUnixDate = self.currUnixDate
       
        self.weatherCondition.append(readableData.list[self.listIndex].weather[0].description) //weathercondtion [0,1,2,3,4] //list[0...39]
        self.currentTemp.append(String(readableData.list[self.listIndex].main.temp))
        print("temp:",readableData.list[self.listIndex].main.temp)
        print("index:",self.listIndex)
        print("array", currentTemp)
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
        diff = 0
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
    
    
    
    
    
    
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
