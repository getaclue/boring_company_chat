//
//  CompanyList.swift
//  chat4work
//
//  Created by A Arrow on 6/7/17.
//  Copyright © 2017 755R3VBZ84. All rights reserved.
//

import Cocoa

class MessageList: NSScrollView {
    
  let list = NSView(frame: NSMakeRect(0,0,220,1560+900))
  
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
  }
  
  func channelDidChange(notification: NSNotification) {
    let name = notification.object as! String
    list.subviews = []
    makeMessages(name: name)
  }
  
  func makeMessages(name:String) {
    for i in 0...81 {
      let imageView = MessageItem(frame: NSMakeRect(10,(CGFloat(i*30)),200,25))
      imageView.setStringValue(val: "\(name) test \(i)")
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
    
    wantsLayer = true
    
    makeMessages(name: "initial")
    
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
 
