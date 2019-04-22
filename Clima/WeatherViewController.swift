//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    @IBOutlet weak var temperatureScaleSwitch: UISwitch!
    
    @IBAction func temperatureScaleSwitchChanged(_ sender: Any) {
        
            temperatureScaleSelector(isFahrenheit: temperatureScaleSwitch.isOn)
        
        
    }
    //Constants
    //let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/forecast"
    let APP_ID = "95a939396aec2f96db8e4e6d0d6279cd"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    
    let locationManager = CLLocationManager() // delivers the location of the phone 
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        temperatureScaleSwitch.isOn = false
        //TODO:Set up the location manager here.
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
     // location data how accourate it depends on
    locationManager.requestWhenInUseAuthorization()
        // trigers authorization pop up when a user uses it
        // you need to go to info.plist and add two descriptsion, that prompts users for their permission to allow their location
        //  Privacy -
    locationManager.startUpdatingLocation()
        //tries to find the gps location of the iphone or ipad
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String:String]){
        Alamofire.request(url, method: .get, parameters : parameters).responseJSON {
            response in
            if response.result.isSuccess {
                // did it manage to get the data from the server?
                
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            } else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json : JSON){
        if let tempResults = json["list"][0]["main"]["temp"].double{
      //if let tempResults = json["main"]["temp"].double {
        
        weatherDataModel.temperature = Int(tempResults - 273.15)
            //print(weatherDataModel.temperature)
        //weatherDataModel.city = json["name"].stringValue
        weatherDataModel.city = json["city"]["name"].stringValue
        //weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.condition = json["list"][0]["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }
        else {
            cityLabel.text = "weather unavailable"
        }
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    func temperatureScaleSelector (isFahrenheit: Bool){
        if isFahrenheit {
            let temperatureInFahrenheit = 32 + Double(weatherDataModel.temperature) * 9/5
            print(temperatureInFahrenheit)
            temperatureLabel.text = String(format: "%.1f", temperatureInFahrenheit)
        } else {
            temperatureLabel.text = "\(weatherDataModel.temperature)°"
        }
    }
    func updateForcastFiveDays(){
        
    }
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    // this method is activated once a location is obtained from location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //the last value in CLLocation is the most accurate one
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            //once the location is found, then stop updating so that the user does not lose battery
            //print("langitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude), altitude = \(location.altitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String:String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
            // app id the api's app id
        }
    }
    
    
    //Write the didFailWithError method here:
    // this method is triggered if there is an error of retriving the users location: due to intenet issue etc
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let params : [String: String] = ["q": city, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
}


