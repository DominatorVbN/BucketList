//
//  CodableMKPointAnnotation.swift
//  BucketList
//
//  Created by dominator on 28/03/20.
//  Copyright © 2020 dominator. All rights reserved.
//

import MapKit

class CodableMKPointAnnotation: MKPointAnnotation, Codable{
    enum CodingKeys: CodingKey{
        case title, subtitle, lattitude, longitute
    }
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        
        let lattitude = try container.decode(CLLocationDegrees.self, forKey: .lattitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitute)
        coordinate = CLLocationCoordinate2D(latitude: lattitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(coordinate.longitude, forKey: .longitute)
        try container.encode(coordinate.latitude, forKey: .lattitude)
        
    }
    
}
