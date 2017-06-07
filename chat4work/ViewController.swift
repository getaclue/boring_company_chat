//
//  ViewController.swift
//  chat4work
//
//  Created by A Arrow on 6/5/17.
//  Copyright © 2017 755R3VBZ84. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

  let leftscroll = CompanyList(frame: NSMakeRect(0,0,70,700))
  let company = CurrentCompany(frame: NSMakeRect(70,0,220,50))
  let channels = ChannelList(frame: NSMakeRect(70,0,220,650))
  let channel = CurrentChannel(frame: NSMakeRect(70+220,0,650,50))
  let rightscroll = MessageList(frame: NSMakeRect(70+220,30,680,250))
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.autoresizesSubviews = true
      
    view.addSubview(leftscroll)
    view.addSubview(company)
    view.addSubview(channels)
    view.addSubview(channel)
    view.addSubview(rightscroll)
  }
    
  override func viewDidAppear() {
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }
}

