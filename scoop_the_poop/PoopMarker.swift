//
//  Marker.swift
//  scoop_the_poop
//
//  Created by Student on 4/11/25.
//

import Foundation
import UIKit

struct PoopMarker: Identifiable {
    var id: Int32
    var started_date: String
    var closed_date: String?
    var longitude: Double
    var latitude: Double
    var image: UIImage?
}
