//
//  UserViewModel.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 27/04/2021.
//

import UIKit
import Combine

struct UserViewModel {
    private let user: User
    
    var getName: String {
        return user.name.first + " " + user.name.last
    }
    
    var getUsername: String {
        return user.login.username
    }
    
    var getGenderAndAnge: String {
        return user.gender.capitalized + ", " + "\(user.dob.age)"
    }
    
    var getDateOfBirth: String {
        guard let date = user.dob.date.convertISODate() else {return ""}
        return date.ordinalStringForDay + " " + date.dayMonthYearString
    }
    
    var getRoadAndNumber: String {
        return "\(user.location.street.number)" + " " + user.location.street.name
    }
    
    var getStateCityCountry: String {
        return "\(user.location.city), \(user.location.state), \(user.location.country)"
    }
    
    var getPhoneNumber: String {
        return user.cell
    }
    
    var getEmailNumber: String {
        return user.email
    }
    
    var getRegistered: String {
        guard let registeredDate = user.registered.date.convertISODate() else {return ""}
        let timzeon = user.registered.date.convertISOToTimzeon()
        
        return "Registered on \(registeredDate.ordinalStringForDay) \(registeredDate.dayMonthYearString), \(registeredDate.hourMinuteString) (\(timzeon))"
    }
    
    init(user: User) {
        self.user = user
    }
    
    func loadImage() -> AnyPublisher<UIImage?, Never> {
        return Just(user.picture.large)
        .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
            let url = URL(string: user.picture.large)!
            return ImageLoader.shared.loadImage(from: url)
        })
        .eraseToAnyPublisher()
    }
}
