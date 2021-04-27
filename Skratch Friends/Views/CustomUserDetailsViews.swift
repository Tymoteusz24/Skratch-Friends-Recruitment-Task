//
//  CustomUserDetailsViews.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 27/04/2021.
//

import UIKit

class UserDetailsView: UIView {
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .top
        stackView.spacing = 16
        return stackView
    }()
    
    lazy var userImage: UIImageView = {
        let userImageView = UIImageView()
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            userImageView.widthAnchor.constraint(equalToConstant: 22),
            userImageView.heightAnchor.constraint(equalToConstant: 22)
          ])
        
        return userImageView
    }()
    
    lazy var subtitleStackView: SubtitleStackView = {
        let stackView = SubtitleStackView(subtitle: true)
        return stackView
    }()
    
    init(image: UIImage, mainText: String, subText: String) {
        super.init(frame: .zero)
        configure()
        subtitleStackView.nameLabel.text = mainText
        subtitleStackView.userNameLabel.text = subText
        
        userImage.image = image
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func configure() {
        self.addSubview(mainStackView)
        mainStackView.addArrangedSubview(userImage)
        mainStackView.addArrangedSubview(subtitleStackView)
        
        self.backgroundColor = C.Color.ultraLight
        self.layer.cornerRadius = 9
        self.clipsToBounds = true
      
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
        ])
    }
}

class PhoneMailDetailsView: UIView {
    lazy var verticalStackViewContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 5
        return stackView
    }()
    
    lazy var phoneStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    lazy var emialStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    lazy var phoneTitleStackView: SubtitleStackView = {
        let stackView = SubtitleStackView(subtitle: false)
        return stackView
    }()
    
    lazy var emialTitileStackView: SubtitleStackView = {
        let stackView = SubtitleStackView(subtitle: false)
        return stackView
    }()
    
    
    lazy var phoneImage: UIImageView = {
        let userImageView = UIImageView()
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.contentMode = .scaleAspectFit
        userImageView.image = C.Image.phoneIcon
        NSLayoutConstraint.activate([
            userImageView.widthAnchor.constraint(equalToConstant: 22),
            userImageView.heightAnchor.constraint(equalToConstant: 22)
          ])
        
        return userImageView
    }()
    
    lazy var emailImage: UIImageView = {
        let userImageView = UIImageView()
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.contentMode = .scaleAspectFit
        userImageView.image = C.Image.emailIcon
        NSLayoutConstraint.activate([
            userImageView.widthAnchor.constraint(equalToConstant: 22),
            userImageView.heightAnchor.constraint(equalToConstant: 22)
          ])
        
        return userImageView
    }()
    
    lazy var subtitleStackView: SubtitleStackView = {
        let stackView = SubtitleStackView(frame: .zero)
        return stackView
    }()
    
    init(email: String, phone: String) {
        super.init(frame: .zero)
        configure()
        phoneTitleStackView.nameLabel.text = phone
        emialTitileStackView.nameLabel.text = email
       
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func configure() {
        self.addSubview(verticalStackViewContainer)
        verticalStackViewContainer.addArrangedSubview(phoneStackView)
        verticalStackViewContainer.addArrangedSubview(emialStackView)
        phoneStackView.addArrangedSubview(phoneImage)
        phoneStackView.addArrangedSubview(phoneTitleStackView)
        
        emialStackView.addArrangedSubview(emailImage)
        emialStackView.addArrangedSubview(emialTitileStackView)
        
        self.backgroundColor = C.Color.ultraLight
        self.layer.cornerRadius = 9
        self.clipsToBounds = true
      
        
        NSLayoutConstraint.activate([
            verticalStackViewContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            verticalStackViewContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            verticalStackViewContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
        ])
    }
}

class SubtitleStackView: UIStackView {
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = C.Color.grayText
        label.font = UIFont(name: C.Font.CircularStdBook, size: 12)
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = C.Color.skratchNavy
        label.font = UIFont(name: C.Font.CircularStdBook, size: 17)
        return label
    }()
    
    init(subtitle:Bool = true) {
        super.init(frame: .zero)
        configureStackView(subtitle: subtitle)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureStackView(subtitle: Bool = true) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .vertical
        self.distribution = .equalSpacing
        self.alignment = .fill
        self.spacing = 2
        
        
        self.addArrangedSubview(nameLabel)
        subtitle ? self.addArrangedSubview(userNameLabel) : nil
        
    }
}



