//
//  ChatLogPresenter.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 15/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation
import RxSwift
import PromiseKit

class ChatMessageViewModel {
    let id: String
    let text: String
    let userImage: UIImage?
    let type: MessageCellType
    let timestamp: Int
    
    init(id: String,
         text: String,
         userImage: UIImage?,
         type: MessageCellType,
         timestamp: Int) {
        self.id = id
        self.text = text
        self.userImage = userImage
        self.type = type
        self.timestamp = timestamp
    }
}

protocol ChatlogInput {
    var viewDidLoad: PublishSubject<()> { get }
    var sendMessage: PublishSubject<()> { get }
    var messageText: Variable<String?> { get }
}

protocol ChatlogOutput {
    var partnerUser: Variable<User?> { get }
    var currentMessages: Variable<[ChatMessageViewModel]> { get }
    var shouldClose: PublishSubject<()> { get }
}

class ChatlogPresenter: ChatlogInput, ChatlogOutput{
    
    let viewDidLoad = PublishSubject<()>()
    let sendMessage = PublishSubject<()>()
    let messageText = Variable<String?>("")
    
    let partnerUser = Variable<User?>(nil)
    let currentMessages = Variable<[ChatMessageViewModel]>([])
    let shouldClose = PublishSubject<()>()
    
    private let messagesAPI: MessageAPIProtocol
    private let usersAPI: UsersAPIProtocol
    private let disposeBag = DisposeBag()
    private let currentUID: String
    private let partnerUID: String
    
    init(users: PartnerUsers, messagesAPI: MessageAPIProtocol, usersAPI: UsersAPIProtocol) {
        currentUID = users.0
        partnerUID = users.1
        
        self.messagesAPI = messagesAPI
        self.usersAPI = usersAPI
        
        viewDidLoad.subscribe { (event) in
            self.messagesAPI.observeMessages(ofUser: self.currentUID, withPartner: self.partnerUID, onReceive: { (message) in
                let messageType: MessageCellType = message.fromID == self.currentUID ? .currentUser : .partnerUser
                
                usersAPI.getUser(withID: message.fromID)
                    .then(execute: { (user) -> Promise<UIImage> in
                        guard let userImgUrlString = user.imgURL,
                            let userImgUrl = URL(string: userImgUrlString) else {
                                throw ImageCacheError.failedToDecodeImage
                        }
                        return ImageCache.shared.image(for: userImgUrl)
                    }).then(execute: { (image) -> Void in
                        self.currentMessages.value
                            .append(ChatMessageViewModel(id: message.id,
                                                         text: message.text,
                                                         userImage: image,
                                                         type: messageType,
                                                         timestamp: message.timestamp))
                    }).catch(execute: { (error) in
                        self.currentMessages.value
                            .append(ChatMessageViewModel(id: message.id,
                                                         text: message.text,
                                                         userImage: nil,
                                                         type: messageType,
                                                         timestamp: message.timestamp))
                    })
            })
            }.addDisposableTo(disposeBag)
        
        sendMessage
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe { (event) in
                guard let messageText = self.messageText.value else { return }
                let timestamp = Int(NSDate().timeIntervalSince1970)
                let message = ChatMessage(id: "",
                                          text: messageText,
                                          toID: self.partnerUID,
                                          fromID: self.currentUID,
                                          timestamp: timestamp)
                self.messagesAPI.send(message: message)
            }.addDisposableTo(disposeBag)
    }
}
