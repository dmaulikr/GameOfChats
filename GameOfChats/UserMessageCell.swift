//
//  UserMessageCell.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 02/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class UserMessageCell: UITableViewCell{
    
    var message: ChatMessage?{
        didSet{
            guard let currentUser = FIRAuth.auth()?.currentUser else { return }
            guard let message = message else { return }
            subTitleLabel.text = message.text
            titleLabel.text = "..."
            let time = Date(timeIntervalSince1970: TimeInterval(message.timestamp))
            timeLabel.text = time.simpleTimeFormat()
            
            var userID = ""
            if currentUser.uid == message.fromID {
                userID = message.toID
            }else if currentUser.uid == message.toID{
                userID = message.fromID
            }
            
            FIRDatabase.database().reference().child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String : AnyObject] else { return }
                guard let user = User.from(dict: dict, withID: snapshot.key) else { return }
                self.user = user
            }, withCancel: nil)
        }
    }
    
    private (set) var user: User?{
        didSet{
            guard let user = user else { return }
            self.titleLabel.text = user.name
            if let url = user.imgURL{
                self.imgURL = URL(string: url)
            }
        }
    }
    
    var imgURL: URL?{
        didSet{
            guard let imgURL = imgURL else {
                self.profileImageView.image = #imageLiteral(resourceName: "winter-logo")
                return
            }
            self.profileImageView.loadCachedImage(fromURL: imgURL, withPlaceHolder: #imageLiteral(resourceName: "winter-logo"))
        }
    }
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.image = #imageLiteral(resourceName: "winter-logo")
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(timeLabel)
        setupImageView()
        setupLabels()
    }
    
    func setupLabels(){
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subTitleLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        subTitleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        
        timeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
    }
    
    func setupImageView(){
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.layer.cornerRadius = 25
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}