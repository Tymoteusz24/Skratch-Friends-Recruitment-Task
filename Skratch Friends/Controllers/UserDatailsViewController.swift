//
//  UserDatailsViewController.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 26/04/2021.
//

import UIKit
import Combine

class UserDatailsViewController: UIViewController {
    
    lazy var userImage: UserAvatarImageView = {
        let userImageView = UserAvatarImageView(frame: .zero)
        
        NSLayoutConstraint.activate([
            userImageView.widthAnchor.constraint(equalToConstant: 72),
            userImageView.heightAnchor.constraint(equalToConstant: 72)
          ])
        
        return userImageView
    }()
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = C.Color.grayText
        label.font = UIFont(name: C.Font.CircularStdBook, size: 17)
        label.text = viewModel.getUsername
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = C.Color.skratchNavy
        label.font = UIFont(name: C.Font.CircularStdBold, size: 24)
        label.text = viewModel.getName
        return label
    }()
    
    lazy var userDetailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 8
        
        return stackView
    }()
    
    lazy var dobUserDetails: UserDetailsView = {
        let view = UserDetailsView(image: C.Image.ballonIcon, mainText: viewModel.getGenderAndAnge, subText: viewModel.getDateOfBirth)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 69)
        ])
        return view
    }()
    
    lazy var locationUserDetails: UserDetailsView = {
        let view = UserDetailsView(image: C.Image.locationIcon, mainText: viewModel.getRoadAndNumber, subText: viewModel.getStateCityCountry)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 69)
        ])
        return view
    }()
    
    
    lazy var phoneAndEmailDetail: PhoneMailDetailsView = {
        let view = PhoneMailDetailsView(email: viewModel.getEmailNumber, phone: viewModel.getPhoneNumber)
        view.translatesAutoresizingMaskIntoConstraints = false
       // view.backgroundColor = .green
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 92)
        ])
        return view
    }()
    
    lazy var registeredLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = C.Color.skratchNavy.withAlphaComponent(0.5)
        label.font = UIFont(name: "CircularStd-Book", size: 12)
        label.textAlignment = .center
        label.text = viewModel.getRegistered
        return label
    }()
    
    var viewModel: UserViewModel
    
    lazy var topIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = C.Color.gray
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 2.5
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 56),
            view.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        return view
    }()
    
    var cancellable: AnyCancellable?
    
    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .white
        self.view.layer.cornerRadius = 30
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.view.addSubview(topIndicator)
        self.view.addSubview(userImage)
        self.view.addSubview(nameLabel)
        self.view.addSubview(userNameLabel)
        self.view.addSubview(userDetailsStackView)
        self.view.addSubview(registeredLabel)
        
        userDetailsStackView.addArrangedSubview(dobUserDetails)
        userDetailsStackView.addArrangedSubview(locationUserDetails)
        userDetailsStackView.addArrangedSubview(phoneAndEmailDetail)
        
        cancellable = viewModel.loadImage().sink { self.userImage.image = $0 }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topIndicator.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
            topIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            userImage.topAnchor.constraint(equalTo: topIndicator.bottomAnchor, constant: 24),
            userImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: userImage.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            userNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant: 0),
            userNameLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            userDetailsStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            userDetailsStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            userDetailsStackView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 24),
            
            registeredLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            registeredLabel.topAnchor.constraint(equalTo: userDetailsStackView.bottomAnchor, constant: 32)
            
        ])
    }
}
