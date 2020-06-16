//
//  Place.swift
//  ToVisitPlaces_Swati_C0772098
//
//  Created by user173890 on 6/16/20.
//  Copyright © 2020 user173890. All rights reserved.
//

import Foundation

class Place: Codable
{

    public var longitude: Double
    public var latitude: Double
    public var title: String
    
    init(longitude: Double, latitude: Double, title: String)
    {
        self.longitude = longitude
        self.latitude = latitude
        self.title = title
    }
}
