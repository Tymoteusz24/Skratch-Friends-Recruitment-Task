//
//  MapViewModel.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 23/04/2021.
//

import Foundation
import Mapbox

class MapViewModel {
    private (set) var networkingManager: NetworkingProtocol!
    
    var numberOfUsers: Int = 5
    
    var url: String {
        return "https://randomuser.me/api/?results=\(numberOfUsers)" + "&inc=name,picture,gender,location,email,login,registered,dob,cell"
    }
    
    var users: [User]?
    
    var imagesDict: [String : UIImageView] = [:]
    
    var annotationPoints: [UserAnnotationPoint] {
        guard let users = users else {return []}
        
        return users.compactMap { UserAnnotationPoint(user: $0)}
    }
    
    init(users: [User]) {
        self.users = users
    }
    
    init(networkingManager: NetworkingProtocol) {
        self.networkingManager = networkingManager
    }
}

extension MapViewModel {
    func populateMap(completion: ((NetworkError?) -> Void)?) {
        networkingManager.performNetworkTask(for: url, type: UserResults.self) { [weak self] (result) in
            switch result {
            case .failure(let error):
                completion?(error)
            case .success(let usersResults):
                self?.users = usersResults.results
                completion?(nil)
            }
        }
    }
}


