//
//  ViewController.swift
//  Xcode-weather
//
//  Created by user on 17.11.2022.
//

import UIKit
import Alamofire
import SwiftyJSON

class CitiesList: UITableViewController {
    
    struct City {
        var name: String
        var temp_c: Double
    }
    
    var cities: [City] = []
    
    let url = "http://api.weatherapi.com/v1/current.json?key=21789a6958ed483c85c140131211201&aqi=no"
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityRow", for: indexPath) as! CityCell
        
        cell.cityName.text = cities[indexPath.row].name
        cell.cityTemp.text = String(cities[indexPath.row].temp_c)
        
        return cell
    }
    
    @IBAction func addCityAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add new city", message: "Enter city name", preferredStyle: .alert)
        alertController.addTextField { textField in textField.placeholder = "City name" }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            guard alertController.textFields![0].text != nil else { return }
            let name = alertController.textFields![0].text!
            self.requestData(city: name)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func requestData(city: String) {
        let params = ["q": city]
        AF.request(url, method: .get, parameters: params).response { [self] response in
            switch response.result {
            case .success(let value):
                let json = JSON(value!)
                let name = json["location"]["name"].stringValue
                let temp_c = json["current"]["temp_c"].doubleValue
                guard !checkCity(name: name) else { return alertController(message: "City already added") }
                cities.append(City(name: name, temp_c: temp_c))
                tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func checkCity(name: String) -> Bool {
        cities.contains { list in
            return list.name == name
        }
    }
    
    func alertController(message: String) {
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
}
