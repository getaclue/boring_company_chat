import Foundation
import RxSwift

enum ChannelApiError: Error {
  case invalidCode
}

protocol ChannelApi {
    
  func getChannels(token: String) -> Observable<Channels>
  func getGroups(token: String) -> Observable<Groups>
  func getIMs(token: String) -> Observable<Ims>
  func getUsers(token: String) -> Observable<Users>
  func getTeamInfo(token: String) -> Observable<Team>
  
}
