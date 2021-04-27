//
//  UIViewController + Extension.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 26/04/2021.
//

import UIKit

protocol ViewControllerForDetailVCProtocol: class {
    func showUserDetailsVC(for user: User)
}


extension ViewControllerForDetailVCProtocol where Self: UIViewController {
    func showUserDetailsVC(for user: User) {
        let viewModel = UserViewModel(user: user)
        
        let vc = BottomSheetContainerViewController(
            bottomSheetViewController: UserDatailsViewController(viewModel: viewModel),
                    bottomSheetConfiguration: .init(
                        height: 546,
                        initialOffset: 0
                    )
                )
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
}