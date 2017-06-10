//
//  CompanyList.swift
//  chat4work
//
//  Created by A Arrow on 6/7/17.
//  Copyright © 2017 755R3VBZ84. All rights reserved.
//

import Cocoa
import Moya
import RxSwift

class MessageList: NSScrollView {
    
  let list = NSView(frame: NSMakeRect(0,0,680,1560+(300*75)))
  var disposeBag = DisposeBag()
  var token = ""
  var channel = ""
  
  func companyDidChange(notification: NSNotification) {
    token = notification.object as! String
  }
  
  func sendMessage(notification: NSNotification) {
    let data = notification.object as! String

    var i = 81
    while i > 0 {
      let prev = list.subviews[i] as! MessageItem
      let item = list.subviews[i-1] as! MessageItem
      i = i - 1
      prev.setStringValue(val: item.getStringValue())
    }
    let item = list.subviews[0] as! MessageItem
    item.setStringValue(val: data)
    
    let provider = RxMoyaProvider<ChatService>()
    let channelApi = ChannelApiImpl(provider: provider)
    
    channelApi.postMessage(token: token, id: channel, text: data).subscribe(
      onNext: { message in
        
        NSLog("\(message.ts)")
        
    },
      onError: { error in
        
    }).addDisposableTo(disposeBag)
  }
  
  func channelDidChange(notification: NSNotification) {
    let b = notification.object as! ButtonWithStringTag
    
    channel = b.stringTag
    
    let provider = RxMoyaProvider<ChatService>()
    let channelApi = ChannelApiImpl(provider: provider)
    
    if b.flavor == "im" {
      channelApi.getHistoryIM(token: token, id: channel).subscribe(
        onNext: { message in
          
          if let m = message.results {
            
            for (i,sv) in self.list.subviews.enumerated() {
              let mi = sv as! MessageItem
              if i < m.count-1 {
                mi.msg.stringValue = m[i].text!
              }
            }
          
          }
          
      },
        onError: { error in
          
      }).addDisposableTo(disposeBag)
    } else if b.flavor == "group" {
      channelApi.getHistoryGroup(token: token, id: channel).subscribe(
        onNext: { message in
          
          if let m = message.results {
            
            for (i,sv) in self.list.subviews.enumerated() {
              let mi = sv as! MessageItem
              if i < m.count-1 {
                mi.msg.stringValue = m[i].text!
              }
            }
            
          }
          
      },
        onError: { error in
          
      }).addDisposableTo(disposeBag)
    } else if b.flavor == "channel" {
      channelApi.getHistoryChannel(token: token, id: channel).subscribe(
        onNext: { message in
          
          if let m = message.results {
            
            for (i,sv) in self.list.subviews.enumerated() {
              let mi = sv as! MessageItem
              if i < m.count-1 {
                mi.msg.stringValue = m[i].text!
              }
            }
            
          }
          
      },
        onError: { error in
          
      }).addDisposableTo(disposeBag)
      
    }
  }
  
  func turnAllOff(notification: NSNotification) {
    for sv in list.subviews {
      let mi = sv as! MessageItem
      mi.turnOff()
    }
  }
  
  func makeMessages(name:String) {
    for i in 0...81 {
      let imageView = MessageItem(frame: NSMakeRect(10,(CGFloat(i*300)),680,250))
      imageView.setStringValue(val: "\(name)")
      list.addSubview(imageView)
    }
  }
  override init(frame frameRect: NSRect) {
    super.init(frame:frameRect);
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(channelDidChange),
      name: NSNotification.Name(rawValue: "channelDidChange"),
      object: nil)
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(sendMessage),
      name: NSNotification.Name(rawValue: "sendMessage"),
      object: nil)
    
    NotificationCenter.default.addObserver(self,
         selector: #selector(turnAllOff),
         name: NSNotification.Name(rawValue: "turnAllOff"),
         object: nil)
    
    NotificationCenter.default.addObserver(self,
         selector: #selector(companyDidChange),
         name: NSNotification.Name(rawValue: "companyDidChange"),
         object: nil)
    
    wantsLayer = true
    
    makeMessages(name: "goto the upper left boring-company-chat menu and select Authorize Tokens")
    
    list.wantsLayer = true
    list.layer?.backgroundColor = NSColor.white.cgColor

    translatesAutoresizingMaskIntoConstraints = true
    autoresizingMask.insert(NSAutoresizingMaskOptions.viewHeightSizable)
    autoresizingMask.insert(NSAutoresizingMaskOptions.viewMinYMargin)
    autoresizingMask.insert(NSAutoresizingMaskOptions.viewMaxYMargin)

    documentView = list
    hasVerticalScroller = true
    //documentView?.scroll(NSPoint(x: 0, y:2000))
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
 
