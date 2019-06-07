/*:
 
 # Measuring the power of an Earthquake.

 
 Earthquakes are recorded by a seismographic network. Each seismic station in the network measures the movement of the ground at that site. The slip of one block of rock over another in an earthquake releases energy that makes the ground vibrate. That vibration pushes the adjoining piece of ground and causes it to vibrate, and thus the energy travels out from the earthquake in a wave.
 
 There are many different ways to measure different aspects of an earthquake:
 
 **Magnitude** is the most common measure of an earthquake's size. It is a measure of the size of the earthquake source and is the same number no matter where you are or what the shaking feels like. The Richter scale is an outdated method for measuring magnitude that is no longer used by the USGS for large, teleseismic earthquakes. The Richter scale measures the largest wiggle (amplitude) on the recording, but other magnitude scales measure different parts of the earthquake. The USGS currently reports earthquake magnitudes using the Moment Magnitude scale, though many other magnitudes are calculated for research and comparison purposes.
 
 **Intensity** is a measure of the shaking and damage caused by the earthquake; this value changes from location to location.
 
 ## Magnitude / Intensity Comparison
 The following table gives intensities that are typically observed at locations near the epicenter of earthquakes of different magnitudes.
 
 Magnitude          Typical Maximum
                    Modified Mercalli Intensity
 ---
 1.0 - 3.0              I
 ---
 3.0 - 3.9              II - III
 ---
 4.0 - 4.9              IV - V
 ---
 5.0 - 5.9              VI - VII
 ---
 6.0 - 6.9              VII - IX
 ---
 7.0 and higher         VIII or higher
 ---
 
 Abbreviated Modified Mercalli Intensity Scale
 **I.** *Not felt except by a very few under especially favorable conditions.*
 
 **II.** *Felt only by a few persons at rest, especially on upper floors of buildings.*
 
 **III.** *Felt quite noticeably by persons indoors, especially on upper floors of buildings. Many people do not recognize it as an earthquake. Standing motor cars may rock slightly. Vibrations similar to the passing of a truck. Duration estimated.*
 
 **IV.** *Felt indoors by many, outdoors by few during the day. At night, some awakened. Dishes, windows, doors disturbed; walls make cracking sound. Sensation like heavy truck striking building. Standing motor cars rocked noticeably.*
 
 **V.** *Felt by nearly everyone; many awakened. Some dishes, windows broken. Unstable objects overturned. Pendulum clocks may stop.*
 
 **VI.** *Felt by all, many frightened. Some heavy furniture moved; a few instances of fallen plaster. Damage slight.*
 
 **VII.** *Damage negligible in buildings of good design and construction; slight to moderate in well-built ordinary structures; considerable damage in poorly built or badly designed structures; some chimneys broken.*
 
 **VIII.** *Damage slight in specially designed structures; considerable damage in ordinary substantial buildings with partial collapse. Damage great in poorly built structures. Fall of chimneys, factory stacks, columns, monuments, walls. Heavy furniture overturned.*
 
 **IX.** *Damage considerable in specially designed structures; well-designed frame structures thrown out of plumb. Damage great in substantial buildings, with partial collapse. Buildings shifted off foundations.*
 
 **X.** *Some well-built wooden structures destroyed; most masonry and frame structures destroyed with foundations. Rails bent.*
 
 **XI.** *Few, if any (masonry) structures remain standing. Bridges destroyed. Rails bent greatly.*
 
 **XII.** *Damage total. Lines of sight and level are distorted. Objects thrown into the air.*
 
*/
 

/*:
 
 # What is the power of an Earthquake.

 We are going to compare the orders of magnitude of earthquakes against TNT.
 
 TNT equivalent is a convention for expressing energy, typically used to describe the energy released in an explosion. The "ton of TNT" is a unit of energy defined by that convention to be 4.184 gigajoules,
 
 A kiloton of TNT can be visualized as a cube of TNT 8.46 metres (27.8 ft) on a side.
 
 The Nagasaki Atomic Bomb has the quialivant of 20 Kilotons of TNT.

 ![Nagasaki Atomic bomb](1024px-Nagasakibomb.jpg)
 
 Each of the following image that appears will represent 20 Kilotons of TNT:
 
 ![Nagasaki Atomic bomb](AtomicBombexplosion.png)
 
 
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


let startTime = "2019-05-25"
let endTime = "2019-05-31"
let minMagnitude = 2.0


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





