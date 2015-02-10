//
//  ViewController.swift
//  SwiftWeaer
//
//  Created by Zheng, Zen on 2/8/15.
//  Copyright (c) 2015 zenvim. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager:CLLocationManager = CLLocationManager()
    
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperature: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        var location:CLLocation = locations[locations.count-1] as CLLocation

        if(location.horizontalAccuracy > 0)
        {
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
            
            self.updateWeatherInfo(location.coordinate.latitude, longitude: location.coordinate.longitude)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func updateWeatherInfo(latitude:CLLocationDegrees, longitude:CLLocationDegrees){
        
        let manager = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
        let params = ["lat":latitude, "lon":longitude, "cnt":0]
        println(params)
        println("test")
        manager.GET(url
            , parameters: params,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                println("JSON " + responseObject.description )
                
                self.updateUISuccess(responseObject as NSDictionary!)
            },
            
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
            })
    }
    
    func updateUISuccess(jsonResult:NSDictionary!) {
        if let tempResult = jsonResult["main"]?["temp"]? as? Double {
            
            var temperature: Double
            temperature = 0
            if (jsonResult["sys"]?["country"]? as String == "US")
            {
                temperature =  round(((temperature - 273.15)*1.8)+32)
            }
            else
            {
                temperature =  round(tempResult - 273.15)
            }
            
            self.temperature.text = "\(temperature)°"
            self.temperature.font = UIFont.boldSystemFontOfSize(60)
            
            var name = jsonResult["name"]? as String
            self.location.font = UIFont.boldSystemFontOfSize(25)
            self.location.text = "\(name)"
            
            var condition = (jsonResult["weather"]? as NSArray)[0]["id"] as Int
            var sunrise = jsonResult["sys"]?["sunrise"]? as Double
            var sunset = jsonResult["sys"]?["sunset"]? as Double
            
            var nightTime = false
            var now = NSDate().timeIntervalSince1970
            
            if (now < sunrise || now > sunset) {
                nightTime = true
            }
            
            self.updateWeatherInfo(condition, nightTime: nightTime)
            
        }
        else {
        }
    }
    
    
    func updateWeatherInfo(condition: Int, nightTime: Bool)
    {
        if (condition < 300) {
            if nightTime
            {
                self.icon.image = UIImage(named: "tstorm1_night")
            }
            else
            {
                self.icon.image = UIImage(named: "tstorm1")
            }
        }
                else if (condition < 500) {
                    self.icon.image = UIImage(named: "light_rain")
        
                }
                    // Rain / Freezing rain / Shower rain
                else if (condition < 600) {
                    self.icon.image = UIImage(named: "shower3")
                }
                    // Snow
                else if (condition < 700) {
                    self.icon.image = UIImage(named: "snow4")
                }
                    // Fog / Mist / Haze / etc.
                else if (condition < 771) {
                    if nightTime {
                        self.icon.image = UIImage(named: "fog_night")
                    } else {
                        self.icon.image = UIImage(named: "fog")
                    }
                }
                    // Tornado / Squalls
                else if (condition < 800) {
                    self.icon.image = UIImage(named: "tstorm3")
                }
                    // Sky is clear
                else if (condition == 800) {
                    if (nightTime){
                        self.icon.image = UIImage(named: "sunny_night")
                    }
                    else {
                        self.icon.image = UIImage(named: "sunny")
                    }
                }
                    // few / scattered / broken clouds
                else if (condition < 804) {
                    if (nightTime){
                        self.icon.image = UIImage(named: "cloudy2_night")
                    }
                    else{
                        self.icon.image = UIImage(named: "cloudy2")
                    }
                }
                    // overcast clouds
                else if (condition == 804) {
                    self.icon.image = UIImage(named: "overcast")
                }
                    // Extreme
                else if ((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)) {
                    self.icon.image = UIImage(named: "tstorm3")
                }
                    // Cold
                else if (condition == 903) {
                    self.icon.image = UIImage(named: "snow5")
                }
                    // Hot
                else if (condition == 904) {
                    self.icon.image = UIImage(named: "sunny")
                }
                    // Weather condition is not available
                else {
                    self.icon.image = UIImage(named: "dunno")
                }
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        println(error)
    }

}

