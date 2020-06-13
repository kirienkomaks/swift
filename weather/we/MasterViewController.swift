//
//  MasterViewController.swift
//  weatherapp2
//
//  Created by Student on 03.06.2020.
//  Copyright © 2020 kk2. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var cities = ["Kiev","Kharkiv","Warsaw"]
    var detailViewController: DetailViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    // MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.city = cities[indexPath.row]
            }
        }
    }
    
    // MARK: Table Vie
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let object = cities[indexPath.row]
        let mainUrl = URL(string: "https://www.metaweather.com/api/location/search/?query=" + object)!
        let task = URLSession.shared.dataTask(with: mainUrl) {(data, response, error) in
            guard let data = data else { return }
            
            let jsonRs = try? JSONSerialization.jsonObject(with: data, options: [])
            let unwrappedJsonRs = jsonRs!
            let arrayJsonRs = unwrappedJsonRs as! [Any]
            let castedJsonRs = arrayJsonRs[0] as! [String:Any]
            let woeid = String((castedJsonRs["woeid"] as! Int))
            let cityDataUrl = URL(string: "https://www.metaweather.com/api/location/" + woeid)!
            
            let locTask = URLSession.shared.dataTask(with: cityDataUrl) {(data, response, error) in
                guard let data = data else { return }
                
                let jsonRs = try? JSONSerialization.jsonObject(with: data, options: [])
                
                let unwrappedJsonRs = jsonRs!
                let castedJsonRs = unwrappedJsonRs as! [String:Any]
                
                let consolidatedWeatherOpt = castedJsonRs["consolidated_weather"]!
                let consolidatedWeather = consolidatedWeatherOpt as! [Any]
                let weatherData = consolidatedWeather as! [[String:Any]]
                let cityData = weatherData[0]
                DispatchQueue.main.async {
                    let url = URL(string: "https://www.metaweather.com/static/img/weather/png/" + (cityData["weather_state_abbr"] as! String) + ".png")
                    
                    let session = URLSession.shared.dataTask(with: url!, completionHandler: {data, response, error in DispatchQueue.main.async {
                        guard let data = data else {return}
                        
                        cell.imageView!.image = UIImage(data: data)
                        }})
                    session.resume()
                    let temperature = NSString(format: "%.2f", (cityData["the_temp"] as! Double)) as String
                    cell.textLabel!.text = object + "," + temperature + " C"
                }
                
            }
            locTask.resume()
        }
        task.resume()
            return cell
        
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
}
