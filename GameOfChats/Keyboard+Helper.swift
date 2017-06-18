//
//  Keyboard+Helper.swift
//  GameOfChats
//
//  Created by John Raymund Catahay on 18/06/2017.
//  Copyright © 2017 John Raymund Catahay. All rights reserved.
//

import Foundation
import RxSwift

func keyboardHeight() -> Observable<CGFloat> {
    return Observable.from([
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow)
            .map { notification -> CGFloat in
                (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
        },
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide)
            .map { _ -> CGFloat in
                0
        }
        ])
        .merge()
}
