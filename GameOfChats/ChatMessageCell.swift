//
//  ChatMessageCell.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 05/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import UIKit
import Anchorage

class ChatMessageCell: UICollectionViewCell {
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    lazy var bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .heroBlue
        imageView.layer.masksToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(imageView)
        addSubview(textLabel)
        
        imageView.leftAnchor == self.leftAnchor + 8
        imageView.widthAnchor == 30
        imageView.heightAnchor == imageView.widthAnchor
        imageView.layer.cornerRadius = 15
        
        bubbleView.topAnchor == self.topAnchor
        bubbleView.bottomAnchor == self.bottomAnchor
        bubbleView.widthAnchor <= 220
        bubbleView.widthAnchor >= 60
        rightBubbleAnchor = bubbleView.rightAnchor == self.rightAnchor - 8
        leftBubbleAnchor = bubbleView.leftAnchor == imageView.rightAnchor + 8
        
        textLabel.edgeAnchors == bubbleView.edgeAnchors + 10
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("")
    }
    
    private var leftBubbleAnchor: NSLayoutConstraint!
    private var rightBubbleAnchor: NSLayoutConstraint!
    
    func layoutCell(withMessage message: ChatMessageViewModel){
        textLabel.text = message.text
        switch message.type {
        case .currentUser:
            imageView.isHidden = true
            bubbleView.backgroundColor = .heroBlue
            textLabel.textColor = .white
            
            leftBubbleAnchor.isActive = false
            rightBubbleAnchor.isActive = true
            break
        case .partnerUser:
            imageView.isHidden = false
            imageView.image = message.userImage
            bubbleView.backgroundColor = .lightGray
            textLabel.textColor = .black
            
            rightBubbleAnchor.isActive = false
            leftBubbleAnchor.isActive = true
            break
        }
    }
}

enum MessageCellType{
    case currentUser, partnerUser
}
