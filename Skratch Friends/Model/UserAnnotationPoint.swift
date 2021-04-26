//
//  UserAnnotationPoint.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 26/04/2021.
//

import Foundation
import Mapbox

class UserAnnotationPoint: MGLPointAnnotation {
    private(set) var user: User!
    
    var imageName: String?
    
    init?(user: User) {
        super.init()
        self.user = user
        
        guard let coord = user.getCoordinates else {return nil}
        print("Configure: \(user.name)")
        self.coordinate = coord
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
