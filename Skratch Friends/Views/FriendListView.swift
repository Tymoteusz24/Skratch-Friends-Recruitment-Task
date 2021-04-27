//
//  FriendListView.swift
//  Skratch Friends
//
//  Created by Tymoteusz Pasieka on 25/04/2021.
//

import UIKit

class FriendListView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "My Friends"
        label.textAlignment = .left
        label.textColor = C.Color.skratchNavy
        label.font = UIFont(name: C.Font.CircularStdBlack, size: 32)
        
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.contentInset.bottom = 70
        tableView.allowsSelection = true
        tableView.isUserInteractionEnabled = true
        return tableView
    }()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        configureConstraints()
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "\(UserTableViewCell.self)")
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.alpha = 0.0
        self.backgroundColor = .white
        self.addSubview(titleLabel)
        self.addSubview(tableView)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalToConstant: 168),
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 76),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            
        ])
        
    }
    
    override func didMoveToSuperview() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1
        }
        tableView.reloadData()
    }
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0.0
        }
    }
}
