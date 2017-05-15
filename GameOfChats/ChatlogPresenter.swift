//
//  ChatLogPresenter.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 15/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation
import RxSwift

protocol ChatlogInput {
    var viewDidLoad: PublishSubject<Bool> { get }
}

protocol ChatlogOutput {
    var partnerUser: Variable<User?> { get }
    var currentMessages: Variable<[ChatMessage]> { get }
    var shouldClose: PublishSubject<Bool> { get }
}

class ChatlogPresenter: ChatlogInput, ChatlogOutput{
    
    let viewDidLoad = PublishSubject<Bool>()
    
    let partnerUser = Variable<User?>(nil)
    let currentMessages = Variable<[ChatMessage]>([])
    let shouldClose = PublishSubject<Bool>()
    
    private let messagesAPI: MessagesAPI
    private let disposeBag = DisposeBag()
    private let currentUID: String
    private let partnerUID: String
    
    init(users: PartnerUsers, messagesAPI: MessagesAPI) {
        currentUID = users.0
        partnerUID = users.1
        self.messagesAPI = messagesAPI
        
        viewDidLoad.subscribe { (event) in
            
            self.messagesAPI.observeMessages(ofUser: self.currentUID, withPartner: self.partnerUID, onReceive: { (message) in
                self.currentMessages.value.append(message)
            })
        }.addDisposableTo(disposeBag)
    }
}

