/*:
 
 # What is the Power of an Earthquake?

 We are going to compare the orders of magnitude of earthquakes against TNT.
 
 TNT equivalent is a convention for expressing energy, typically used to describe the energy released in an explosion. The "ton of TNT" is a unit of energy defined by that convention to be 4.184 gigajoules,
 
 A kiloton of TNT can be visualized as a cube of TNT 8.46 metres (27.8 ft) on a side.
 
 The Nagasaki Atomic Bomb has the quialivant of 20 Kilotons of TNT.

 ![Nagasaki Atomic bomb](1024px-Nagasakibomb.jpg)
 
 Each of the following image that appears will represent 20 Kilotons of TNT:
 
 ![Nagasaki Atomic bomb](AtomicBombexplosion.png)
 
 
 # How many TNT Bombs is that?.
 
 Press the **"Run my Code"** to access Earthquake data for the specified date range and Magnitude.
 
 The map will show the Energy of the Earthquake in Giga Joules and the number of equivalent (1 Tonne) TNT Bombs
 
 *Data is limited to 20,000 records if this exceeds this no data is returned.*
 */


//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//


// Add a calculation entry for students.  They should be able to enter a earthquake magnitude and then a number of nuclear explosion icons will appear to represent the entry of the quake.  1 icon = 20 ktn.  The icon is in the resources filder but I think I need to shrink it.  The mathematics for quakes is in the following link:  https://earthquake.usgs.gov/learn/topics/calculator.php

import UIKit
import MapKit
import PlaygroundSupport


let str = "Live Earthquake Data"


struct EarthQuakeInfo: Codable {
    let type: String
    let metadata: MetaData
    let features: [Features]
    
    enum CodingKeys: String, CodingKey {
        case type
        case metadata
        case features
    }
}

struct MetaData: Codable {
    let generated: Int
    let title: String
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case generated
        case title
        case count
    }
}

struct Features: Codable {
    let type: String
    let properties: FeaturesProperties
    let geometry: FeaturesGeometry
    
    enum CodingKeys: String, CodingKey {
        case type
        case properties
        case geometry
    }
}

struct FeaturesProperties: Codable {
    let mag: Double
    let place: String
    let time: Int
    let url: URL
    let type: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case mag
        case place
        case time
        case url
        case type
        case title
    }
}

struct FeaturesGeometry: Codable {
    let type: String
    let coordinates: [Double]
    
    enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }
}

func fetchEarthQuakeInfo(endTime: String, startTime: String, minMagnitude: Double, completion: @escaping (EarthQuakeInfo?) -> Void) {
    let baseURL = "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson"
    let url = URL(string: baseURL + "&endtime=\(endTime)" + "&starttime=\(startTime)" + "&minmagnitude=\(minMagnitude)")!
    
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        
        let jsonDecoder = JSONDecoder()
        if let data = data,
            let earthQuakeInfo = try? jsonDecoder.decode(EarthQuakeInfo.self, from: data) {
            print(earthQuakeInfo)
            completion(earthQuakeInfo)
            //We'll convert this into an extension so that at any time we can reuse and convert EarthQuakeInfo struct into a bunch of annotations.
            
            
        } else {
            print("Either no data was returned, or data was not properly decoded.")
        }
    }
    task.resume()
}


extension EarthQuakeInfo {
    // Don't access any varablees outside the scope inside an extension bad stuff will happen
    var asAnnotations: [MKPointAnnotation] {
        print(self)
        var annotations = [MKPointAnnotation]()
        for i in self.features {
            
            if let _ = i.geometry.coordinates.first {
                //We're doing this inside the if let because if we don't have proper coorindates then we don't want to add a marker with bad coordinates we'll want to skip it (defensive)
                let annotation = MKPointAnnotation()
                let location = CLLocationCoordinate2DMake(Double(i.geometry.coordinates[1]), Double(i.geometry.coordinates[0]))
                print(location)
                let energyGenerated = pow(10,(i.properties.mag*1.5)+4.8)
                let energyGeneratedGJ = energyGenerated/pow(10,9)
                let bombEquivalent = energyGenerated/4184000000
                annotation.coordinate = location
                annotation.title = "\(String(format: "%.3f", (energyGeneratedGJ)))GJ's or \(String(format: "%.3f", bombEquivalent)) TNT 💣's"
                annotations.append(annotation)
            }
        }
        
        return annotations
    }
}
// create a MKMapView
let mapView = MKMapView(frame: CGRect(x:0, y:0, width:800, height:800))

// Define a region for our map view
var mapRegion = MKCoordinateRegion()

mapRegion.center = CLLocationCoordinate2D(latitude: -8.693793, longitude: 115.162216)
mapRegion.span.latitudeDelta = 0.02
mapRegion.span.longitudeDelta = 0.02

mapView.setRegion(mapRegion, animated: true)
mapView.mapType = .hybridFlyover

let camera = MKMapCamera(lookingAtCenter: mapRegion.center, fromDistance: 20000000, pitch: 30, heading: 0)

mapView.camera = camera


//#-end-hidden-code

let startTime = /*#-editable-code start date*/"2019-05-25"/*#-end-editable-code*/
let endTime = /*#-editable-code start date*/"2019-05-31"/*#-end-editable-code*/
let minMagnitude = /*#-editable-code start date*/2.0/*#-end-editable-code*/


//#-hidden-code


fetchEarthQuakeInfo(endTime: endTime, startTime: startTime, minMagnitude: minMagnitude) { (fetchedInfo) in
    if let fetchedInfo = fetchedInfo {
        print(fetchedInfo)
        print(fetchedInfo.asAnnotations)
        // Do UI work on the main thread
        DispatchQueue.main.async {
            mapView.addAnnotations(fetchedInfo.asAnnotations)
        }
        // Here we are "opening up" the the optional fetched info that we are returning in our closure
    } else {
        print("Fetch Failed")
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = mapView

//#-end-hidden-code



