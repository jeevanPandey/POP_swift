

import Foundation
import UIKit

protocol DataLoading {
  associatedtype DataLoader
  var appState: AppState<DataLoader> { get set }

  var customLoadingView: UIView { get }
  var customErrorView: UIView { get }

  func updateUI()
}

enum AppState<Content> {
  case loading
  case populated([Content])
  case empty
  case error(Error)
  case paging([Content], next: Int)

  var currentRecords: [Content] {
    switch self {
    case .populated(let content):
      return content
    case .paging(let contents, _):
      return contents
    default:
      return []
    }
  }
}

extension DataLoading where Self: UIViewController {
  func updateUI() {
    switch appState {
    case .loading:
      print("this is loading")
      showLoaderView()
     // self.view.addSubview(customLoadingView)
    //  self.tableFooterView = customLoadingView

    case .error(let error):
       print("this is error",error.localizedDescription)
     // self.tableFooterView = customErrorView
      showErrorField(errorDesc: error.localizedDescription)
    case .populated(let recording):
     // self.tableFooterView = nil
      showPopulatedTable()
       print("this is recording",recording.count)
    case .empty:
       print("this is empty field")
      showErrorField(errorDesc: "No data found")
     // self.tableFooterView = customErrorView
    case .paging(_, let next):
      // self.tableFooterView = nil
       print("this is paging ....")
      showPagingField()
    }
  }

  func showErrorField(errorDesc:String) {
    customLoadingView.superview?.isHidden = false
    customLoadingView.isHidden = true
    customErrorView.isHidden = false

  }
  func showLoaderView() {
    customLoadingView.superview?.isHidden = false
    customLoadingView.isHidden = false
    customErrorView.isHidden = true
  }

  func showPopulatedTable() {
    customLoadingView.superview?.isHidden = true
    customLoadingView.isHidden = true
    customErrorView.isHidden = true

  }
  func showPagingField() {
    customLoadingView.superview?.isHidden = true
    customLoadingView.isHidden = false
    customErrorView.isHidden = true

  }
}

