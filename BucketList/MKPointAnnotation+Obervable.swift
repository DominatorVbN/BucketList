//
//  MKPointAnnotation+Obervable.swift
//  MapKitInSwiftUI
//
//  Created by dominator on 23/02/20.
//  Copyright © 2020 dominator. All rights reserved.
//

import MapKit

extension MKPointAnnotation: ObservableObject{
    public var wrappedTitle: String{
        get{
            title ?? ""
        }
        set{
            title = newValue
        }
    }
    
    public var wrappedSubtitle: String{
        get{
            subtitle ?? ""
        }
        set{
            subtitle = newValue
        }
    }
}
