//
//  MessagesAPI.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 14/05/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation
import FirebaseDatabase

enum MessagesError: Error{
    case failedToParseData
}

protocol MessageAPIProtocol {
    func observeLastMessages(ofUser uid: String, onReceive: @escaping (_ message: ChatMessage) -> Void)
    func observeMessages(ofUser currentUID: String, withPartner partnerUID: String, onReceive: @escaping (_ message: ChatMessage) -> Void)
    func send(message: ChatMessage)
}

class MessagesAPI: MessageAPIProtocol{
    
    func observeLastMessages(ofUser uid: String, onReceive: @escaping (_ message: ChatMessage) -> Void){
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages")
        let messagesRef = FIRDatabase.database().reference().child("messages")
            
        userMessagesRef.child(uid).observe(.childAdded, with: { (snapshot) in
            userMessagesRef.child(uid).child(snapshot.key).queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
                messagesRef.child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dict = snapshot.value as? [String : AnyObject] else { return }
                    guard let message = ChatMessage.from(dict: dict, withKey: snapshot.key) else { return }
                    onReceive(message)
                }, withCancel: nil)
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func observeMessages(ofUser currentUID: String, withPartner partnerUID: String, onReceive: @escaping (_ message: ChatMessage) -> Void){
        guard !currentUID.isEmpty, !partnerUID.isEmpty else { return }
        
        let messagesRef = FIRDatabase.database().reference().child("messages")
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages")
        
        userMessagesRef.child(currentUID).child(partnerUID).observe(.childAdded, with: { (snapshot) in
            messagesRef.child(snapshot.key).observe(.value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String : AnyObject] else { return }
                guard let message = ChatMessage.from(dict: dict, withKey: snapshot.key) else { return }
                onReceive(message)
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func send(message: ChatMessage){
        let messagesRef = FIRDatabase.database().reference().child("messages")
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages")
        let newMessageRef = messagesRef.childByAutoId()
        
        newMessageRef.setValue(message.getValue()) { (error, ref) in
            guard error == nil else { return }
            userMessagesRef.child(message.fromID).child(message.toID).updateChildValues([ref.key : 1])
            userMessagesRef.child(message.toID).child(message.fromID).updateChildValues([ref.key : 1])
        }
    }
}
