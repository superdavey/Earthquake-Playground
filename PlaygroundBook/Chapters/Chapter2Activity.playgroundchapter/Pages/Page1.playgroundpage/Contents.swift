/*:
 
 ### Measuring the frequency of Earthquakes
 
 (Press the "Run my Code" to access live Earthquake data.)
 
 As you have already learnt the Earth is always moving, though slowly.  When the Earth moves suddnely and quickly we refer to that event as an earthquake.
 
 Modern data collection is important to understand geographic events.  Using code we can access live data from the United Stated Geogrphical Services databases.
 
 */

/*:
 
 ### Choosing your own data
 
 (Press the "Run my Code" to access live Earthquake data.)
 
 Complete the fields to display data
 
 ## Data is limited to 20,000 records if this exceeds this no data is returned.
 
 */

///#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//



import UIKit
import MapKit
import PlaygroundSupport

PlaygroundPage.current.liveView = instantiateLiveView()
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
                annotation.coordinate = location
                annotation.title = i.properties.title
                annotations.append(annotation)
            }
        }
        
        //        if let annotations = annotations {
        //
        //            annotations.canShowCallout = true
        //            annotations.animatesDrop = true
        //            annotations.calloutOffset = CGPoint(x: -5, y: 5)
        //            annotations.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        //
        //        }
        
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
