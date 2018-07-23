
import UIKit

class MainViewController: UIViewController,DataLoading {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var loadingView: UIView!
  @IBOutlet weak var emptyView: UIView!
  @IBOutlet weak var errorLabel: UILabel!
  @IBOutlet weak var errorView: UIView!

  @IBOutlet var smallLoaderView: UIView!

  var appState: AppState<Recording?> = AppState.loading {
    didSet {
      updateUI()
     // setPageFooter()
      tableView.reloadData()
    }
  }

  var customLoadingView:UIView {
      return loadingView
  }
  var customErrorView:UIView  {
        return errorView
    }

  let searchController = UISearchController(searchResultsController: nil)
  let networkingService = NetworkingService()
  let darkGreen = UIColor(red: 11/255, green: 86/255, blue: 14/255, alpha: 1)
  var error: Error?

  override func viewDidLoad() {
    
    super.viewDidLoad()
    title = "Chirper"
    activityIndicator.color = darkGreen
    prepareNavigationBar()
    prepareSearchBar()
    prepareTableView()
    loadRecordings()
  }


  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    searchController.searchBar.becomeFirstResponder()
  }
  
  // MARK: - Loading recordings
  
  @objc func loadRecordings() {
    appState = .loading
    loadPage(1)
  }

  func update(response: RecordingsResult) {
    if let recordings = response.recordings, !recordings.isEmpty {
      tableView.tableFooterView = nil
    } else if let error = response.error {

      appState = .error(error)

      return
    }
    guard let newRecordings = response.recordings,
      !newRecordings.isEmpty else {
        appState = .empty
        return
    }

    var allRecordings =   appState.currentRecords as! [Recording]
     allRecordings.append(contentsOf: newRecordings)
    
    if response.hasMorePages {
      appState = .paging(allRecordings, next: response.nextPage)
    } else {
      appState = .populated(newRecordings)
    }

  }

  func loadPage(_ page: Int) {

    self.appState = .loading
    let query = searchController.searchBar.text
    networkingService.fetchRecordings(matching: query, page: page) { [weak self] response in

      guard let `self` = self else {
        return
      }

      self.searchController.searchBar.endEditing(true)

      self.update(response: response)
    }
  }
  
  // MARK: - View Configuration
  
  func prepareSearchBar() {
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    searchController.searchBar.autocapitalizationType = .none
    searchController.searchBar.autocorrectionType = .no
    
    searchController.searchBar.tintColor = .white
    searchController.searchBar.barTintColor = .white
    
    let whiteTitleAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
    let textFieldInSearchBar = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
    textFieldInSearchBar.defaultTextAttributes = whiteTitleAttributes
    
    navigationItem.searchController = searchController
    searchController.searchBar.becomeFirstResponder()
  }
  
  func prepareNavigationBar() {
    navigationController?.navigationBar.barTintColor = darkGreen
    
    let whiteTitleAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    navigationController?.navigationBar.titleTextAttributes = whiteTitleAttributes
  }
  
  func prepareTableView() {
    tableView.dataSource = self
    
    let nib = UINib(nibName: BirdSoundTableViewCell.NibName, bundle: .main)
    tableView.register(nib, forCellReuseIdentifier: BirdSoundTableViewCell.ReuseIdentifier)
    let placeholedrView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44))
    placeholedrView.addSubview(customLoadingView)
    placeholedrView.addSubview(customErrorView)
    tableView.tableFooterView = placeholedrView
  }


  func setPageFooter() {
    switch appState {
    case .loading:
      tableView.tableFooterView = loadingView
    case .error(let error):
      errorLabel.text = error.localizedDescription
      tableView.tableFooterView = errorView
    case .empty:
      tableView.tableFooterView = emptyView
    case .populated:
      tableView.tableFooterView = nil
    case .paging:
      tableView.tableFooterView = smallLoaderView
    }
  }

}

// MARK: -

extension MainViewController: UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar,
                 selectedScopeButtonIndexDidChange selectedScope: Int) {
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    NSObject.cancelPreviousPerformRequests(withTarget: self,
                                           selector: #selector(loadRecordings),
                                           object: nil)
    
    perform(#selector(loadRecordings), with: nil, afterDelay: 0.5)
  }
  
}

extension MainViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return appState.currentRecords.count
   // return state.currentRecordings.count
   // return recordings?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: BirdSoundTableViewCell.ReuseIdentifier)
      as? BirdSoundTableViewCell else {
        return UITableViewCell()
    }


    cell.load(recording: appState.currentRecords[indexPath.row]! )
    if case .paging(_, let nextPage) = appState,
      indexPath.row == appState.currentRecords.count - 1 {
      loadPage(nextPage)
    }
    return cell
  }
}

