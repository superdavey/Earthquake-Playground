
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//

/*:
 ### What causes earthquakes?
 
 
The Earth's surface if always moving even if you cannot feel it.
 
 

 */



//: A UIKit based Playground for presenting user interface

//#-hidden-code
import UIKit
import PlaygroundSupport

let view = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 400))
view.backgroundColor = .white
let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 600, height: 400))
view.addSubview(imageView)


if let sample = Bundle.main.path(forResource: "tectonicPlates", ofType: "png") {
    let image = UIImage(contentsOfFile: sample)
    imageView.image = image
}

PlaygroundPage.current.liveView = view
PlaygroundPage.current.liveView

//#-end-hidden-code







