//
//  ViewController.swift
//  WeatherMKiriienko
//
//  Created by Student on 30/05/2020.
//  Copyright © 2020 Student. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var labelSity: UILabel!
    
    @IBOutlet weak var labelTemp: UILabel!
    
    @IBOutlet weak var labelWind: UILabel!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchBar.delegate = self
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
extension ViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let url = URL(string: "http://api.weatherstack.com/current?access_key=e496bd3c1cc0ed2a4ef8f6f2833d3184&query=\(searchBar.text!)")
        
        var locationName: String?
        var tempC: Double?
        var wind: Double?
        var wImg: String?
        var image: UIImage?
       
        let task = URLSession.shared.dataTask(with: url!){[weak self](data, response, error) in
            if let data = data{
                if let jsonString = String(data:data, encoding: .utf8){
                    print(jsonString)
                }
            }
            do{
                let json  = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                if let location = json["location"]{
                    locationName = location["name"] as? String
                    print(locationName)
                    
                }
                if let current = json["current"]{
                    tempC = current["temperature"] as? Double
                    print(tempC)
                    wind = current["wind_speed"] as? Double
                    let imgArray = current["weather_icons"] as! [String]
                    wImg = imgArray[0] as? String
                    print(wImg)
                    let urlImage = URL(string:wImg!)
                    
                    
                    
                    let imgLoader = URLSession.shared.dataTask(with: urlImage!){(data, response, error) in
                        if let imageData = data{
                            image=UIImage(data:imageData)
                        }
                    }
                    imgLoader.resume()
                }
                
                DispatchQueue.main.async {
                    self?.labelSity.text = locationName
                    self?.labelTemp.text = "\(tempC!)"
                    self?.labelWind.text = "\(wind!)"
                    self?.weatherImage.image = image
                }
            }
            catch let jsonError{
                print(jsonError)
            }
        }
        task.resume()
        
        
        
    }

}

