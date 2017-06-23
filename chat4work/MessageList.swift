//
//  MessageList.swift
//  chat4work
//
//  Created by A Arrow on 6/7/17.
//  Copyright © 2017 755R3VBZ84. All rights reserved.
//

import Cocoa
import Moya
import RxSwift
import RealmSwift

class MessageList: NSScrollView {
    
  let list = NSView(frame: NSMakeRect(0,0,680,1560+(300*75)))
  var disposeBag = DisposeBag()
  var team:Team?
  var channel = ""
  
  func companyDidChange(notification: NSNotification) {
    team = notification.object as? Team
  }


  func rtmMessage(notification: NSNotification) {
    let json = notification.object as! [String: Any]
    //NSLog("\(json)")
    //2017-06-11 03:53:46.014074+0000 boring-company-chat[7958:82613] ["team": T035N23CL, "source_team": T035N23CL, "user": U035LF6C1, "text": wefwef, "channel": D1KD59XH9, "type": message, "ts": 1497153225.487018]
    
    let c = json["channel"] as! String

    /*
    let t = json["text"] as! String
    let user = json["user"] as! String
    if c == self.channel {
      everyOneMoveUp(data: t, user: user)
    } */
    
    if c == self.channel {
      
      let bwst = ButtonWithStringTag(frame: NSMakeRect(10,(CGFloat(30)),200,25))
      bwst.stringTag = c
      if c[c.startIndex] == "D" {
        bwst.flavor = "im"
      }
      if c[c.startIndex] == "C" {
        bwst.flavor = "channels"
      }
      if c[c.startIndex] == "G" {
        bwst.flavor = "groups"
      }
      bwst.team = self.team
    
      NotificationCenter.default.post(
        name:NSNotification.Name(rawValue: "channelDidChange"),
        object: bwst)
      
      
    }
  }
  
  func everyOneMoveUp(data: String, user: String) {
    var i = 81
    while i > 0 {
      let prev = list.subviews[i] as! MessageItem
      let item = list.subviews[i-1] as! MessageItem
      i = i - 1
      prev.setStringValue(val: item.getStringValue())
    }
    let item = list.subviews[0] as! MessageItem
    item.setStringValue(val: data)
    item.user.stringValue = user
  }
  
  func sendMessage(notification: NSNotification) {
    guard let team = team else {
      
      // alert('no team set yet');
      return
    }
    
    
    let data = notification.object as! String

    everyOneMoveUp(data: data, user: "me")
    
    let provider = RxMoyaProvider<ChatService>()
    let channelApi = ChannelApiImpl(provider: provider)
    
    channelApi.postMessage(token: team.token!, id: channel, text: data).subscribe(
      onNext: { message in
        
        NSLog("\(String(describing: message.ts))")
        
    },
      onError: { error in
        
    }).addDisposableTo(disposeBag)
  }
  
  func channelDidChange(notification: NSNotification) {
    guard let team = team else { return }
    
    let b = notification.object as! ButtonWithStringTag
    
    channel = b.stringTag
    
    let provider = RxMoyaProvider<ChatService>()
    let channelApi = ChannelApiImpl(provider: provider)
    
    for i in 0...81 {
      let mi = self.list.subviews[i] as! MessageItem
      mi.user.stringValue = ""
      mi.msg.stringValue = ""
      mi.time.stringValue = ""
    }
    
    Observable.zip(
      channelApi.getUsers(token: team.token!),
      channelApi.getHistoryByFlavor(token: team.token!, id: channel, flavor: b.flavor, count: 100, unreads: 0)) { (users, messages) in
        var UserHash = ["default":"system"]
        if let u = users.results {
          
          u.forEach({
            (user) in
            UserHash[user.id!] = user.name
          })
        }
        
        var lastUser = ""
        var lastTime = ""
        var MsgList = Array<String>()
        var NameList = Array<String>()
        var TimeList = Array<String>()
        var HeightList = Array<CGFloat>()
        var buffer = ""
        
 
        
        if (messages.results != nil && (messages.results?.count)! > 0) {

          NotificationCenter.default.post(
            name:NSNotification.Name(rawValue: "markChannel"),
            object: ["team": team, "channel": self.channel, "ts": messages.results?[0].ts ?? "",
            "now": NSDate().timeIntervalSince1970])
          
          for (_,m) in (messages.results?.enumerated())! {
            
            if m.user != lastUser && lastUser != "" {
              MsgList.append(buffer)
              NameList.append(lastUser)
              TimeList.append(lastTime)
              
              let constraintRect = CGSize(width: 680, height: 3000)
              
              let boundingBox =  buffer.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: NSFont.systemFont(ofSize: 14.0)], context: nil)
              
              HeightList.append(boundingBox.height)
              
              buffer = ""
            }
            buffer = m.text! + "\n" + buffer
            
            lastUser = "default"
            if m.user != nil {
              lastUser = m.user!
            }
            lastTime = m.ts!
          }
          MsgList.append(buffer)
          
          let constraintRect = CGSize(width: 680, height: 3000)
          
          let boundingBox =  buffer.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: NSFont.systemFont(ofSize: 14.0)], context: nil)
          
          NameList.append(lastUser)
          HeightList.append(boundingBox.height)
          TimeList.append(lastTime)
          
          var curY = CGFloat(0.0)
          
          for (i,sv) in self.list.subviews.enumerated() {
            let mi = sv as! MessageItem
            
            mi.frame = NSRect(x: 10, y: curY, width: 680, height: 100+25)
            
            if i < MsgList.count {
              
              let myi = i
              
              mi.msg.stringValue = MsgList[myi]
              mi.time.stringValue = String(describing: HeightList[myi])
              mi.frame = NSRect(x: 10, y: curY, width: 680, height: HeightList[myi]+25)
              mi.msg.frame = NSRect(x: 5, y: 0, width: 680, height: HeightList[myi])
              mi.user.frame = NSRect(x: 5, y: HeightList[myi], width: 680, height: 25)
              mi.time.frame = NSRect(x: 150, y: HeightList[myi], width: 680, height: 25)
              
              curY += HeightList[myi]+35
              
              mi.user.stringValue = UserHash[NameList[myi]]!
              mi.time.stringValue = (Double(TimeList[myi])?.getDateFromUTC().timeAgoSinceNow(useNumericDates: true))!
              mi.time.stringValue = mi.time.stringValue + " " + (Double(TimeList[myi])?.getDateStringFromUTC())!
            }
          }
          
          
        }

      }
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .observeOn(MainScheduler.instance)
      .subscribe(
        onError: { error in
          NSLog("1111 \(error)")
          
          for i in 0...81 {
            let mi = self.list.subviews[i] as! MessageItem
            mi.user.stringValue = ""
            mi.msg.stringValue = "there was an http api error, try again"
            mi.time.stringValue = ""
          }
          
        }
      )
      .addDisposableTo(disposeBag)
    
  }
  
  func teamLogout(notification: NSNotification) {
    // remove db
    // refresh gui
    
    // col may not be there if fresh
    let realm = try! Realm()
    
    try! realm.write {
      let t = self.team?.id
      let col = realm.objects(ChannelObjectList.self).filter("team = %@", t!).first!
      realm.delete(col)
    }
    
    let defaults = UserDefaults.standard
    let existing = defaults.value(forKey: "bcc_teams") as! Array<String>
    if existing.count == 1 {
      
      defaults.removeObject(forKey: "bcc_\(existing[0])")
      defaults.removeObject(forKey: "bcc_teams")
    } else {
      
      var to_save = [] as Array<String>
      for team in existing {
        if team != self.team?.id {
          to_save.append(team)
          continue
        }
        defaults.removeObject(forKey: "bcc_\(team)")
      }
      
      defaults.set(to_save, forKey: "bcc_teams")
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
      let imageView = MessageItem(frame: NSMakeRect(10,(CGFloat(i*110)),680,100))
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

    NotificationCenter.default.addObserver(self,
         selector: #selector(rtmMessage),
         name: NSNotification.Name(rawValue: "rtmMessage"),
         object: nil)
    
    NotificationCenter.default.addObserver(self,
         selector: #selector(teamLogout),
         name: NSNotification.Name(rawValue: "teamLogout"),
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
 
