//
//  UserTableViewCell.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 26/04/2021.
//

import UIKit
import Combine

class UserTableViewCell: UITableViewCell {
    
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var textStackView: UIStackView = {
        let textStackView = UIStackView()
        textStackView.axis = .vertical
        textStackView.distribution = .equalSpacing
        textStackView.alignment = .leading
        textStackView.spacing = 2
        return textStackView
    }()
    
    lazy var userImage: UIImageView = {
        let userImageView = UIImageView()
        userImageView.layer.masksToBounds = false
        userImageView.layer.cornerRadius = 27
        userImageView.clipsToBounds = true
        userImageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            userImageView.widthAnchor.constraint(equalToConstant: 54),
            userImageView.heightAnchor.constraint(equalToConstant: 54)
          ])
        
        return userImageView
    }()
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = C.Color.gray
        label.font = UIFont(name: C.Font.CircularStdBook, size: 15)
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = C.Color.skratchNavy
        label.font = UIFont(name: C.Font.CircularStdBook, size: 17)
        return label
    }()
    
    private var cancellable: AnyCancellable?
    private var animator: UIViewPropertyAnimator?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(userImage)
        mainStackView.addArrangedSubview(textStackView)
        textStackView.addArrangedSubview(nameLabel)
        textStackView.addArrangedSubview(userNameLabel)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
             ])
    }
    
    func configure(with user: User) {
        nameLabel.text = user.name.first + " " + user.name.last
        userNameLabel.text = user.login.username
        cancellable = loadImage(for: user).sink { [unowned self] image in self.showImage(image: image) }
    }
    
    private func showImage(image: UIImage?) {
        userImage.alpha = 0.0
        animator?.stopAnimation(false)
        userImage.image = image
        animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.userImage.alpha = 1.0
        })
    }
    
    private func loadImage(for user: User) -> AnyPublisher<UIImage?, Never> {
        return Just(user.picture.large)
        .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
            let url = URL(string: user.picture.large)!
            return ImageLoader.shared.loadImage(from: url)
        })
        .eraseToAnyPublisher()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImage.alpha = 0.0
        userImage.image = nil
        cancellable?.cancel()
        animator?.stopAnimation(true)
    }
}
