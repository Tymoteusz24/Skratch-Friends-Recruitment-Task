//
//  User.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 24/04/2021.
//

import Foundation
import MapKit

struct UserResults: Codable {
    let results: [User]
}

struct User: Codable {
    let name: Name
    let gender: String
    let picture: Picture
    let login: Login
    let dob: DateOfBirth
    let location: Location
    let cell: String
    let email: String
    let registered: Registered
}

extension User {
    var getCoordinates: CLLocationCoordinate2D? {
        guard let lat = CLLocationDegrees(location.coordinates.latitude), let long = CLLocationDegrees(location.coordinates.longitude) else {return nil}
        
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}

struct Name: Codable {
    let first: String
    let last: String
}

struct Picture: Codable {
    let large: String
    let thumbnail: String
    let medium: String
}

struct Login: Codable {
    let username: String
}

struct DateOfBirth: Codable {
    let date: String
    let age: Int
}

struct Location: Codable {
    let street: Street
    let city: String
    let country: String
    let state: String
    let coordinates: Coordinates
    
    struct Street: Codable {
        let number: Int
        let name: String
    }
    
    struct Coordinates: Codable {
        let latitude: String
        let longitude: String
    }
}

struct Registered: Codable {
    let date: String
}




