
import UIKit
import Cartography
import RealmSwift


class SearchViewController: UIViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UserAlertProtocol {
    
    fileprivate var searchController : UISearchController!
    fileprivate var tableView: UITableView!
    fileprivate var firstTime:Bool = true
    fileprivate var searchText:String = ""
    fileprivate var tagResult:[SearchSection] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    
    fileprivate var viewModel:ViewModelSearch!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        layoutTableView()
        layoutSearchContoroller()
        viewModel = ViewModelSearch()
    }



    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showKeyboard()
    }
    
    func showKeyboard()
    {
        if firstTime {
            self.searchController.isActive = true

            DispatchQueue.main.async {
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[unowned self] _ in
                self.searchController.searchBar.becomeFirstResponder()
            }
            firstTime = false
        }else{
        }
    }
    
    deinit {
        print("deinit search controller")
    }
    
    
    func dismissView()
    {
        
        UIView.animate(withDuration: 0.0, animations: {[unowned self] in
            self.view.backgroundColor = .clear
            self.navigationItem.titleView?.alpha = 0.0
            self.navigationController?.navigationBar.alpha = 0.0
            self.navigationController?.view.alpha = 0.0
            self.tableView.alpha = 0.0
        }) { (finish) in
            self.navigationController?.dismiss(animated: false, completion: nil)
        }
    }
    
    func getAssets(tag:String, sectionType:SearchSectionType)
    {
        guard let realm = try? Realm() else {
            return
        }
    
        switch sectionType {
        case .adress: let result = realm.objects(Asset.self).filter("location.adress == '\(tag)'") ; print(result)
        case .city: let result = realm.objects(Asset.self).filter("location.city == '\(tag)'") ; print(result)
        case .country: let result = realm.objects(Asset.self).filter("location.country == '\(tag)'") ; print(result)

        default: break
        }
    }
    
  
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchController.searchBar.endEditing(true)


    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: layout views


extension SearchViewController
{
    func layoutSearchContoroller()
    {
        searchController = UISearchController(searchResultsController:  nil)
        view.backgroundColor = .white
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Enter keyword (e.g. iceland)", comment: "")
        searchController.searchBar.sizeToFit()
        
        self.navigationItem.titleView = searchController.searchBar
        self.navigationItem.title = "Search"
        self.definesPresentationContext = true
    }
    
    func layoutTableView()
    {
        tableView = UITableView(frame: self.view.frame, style: .plain)
        self.view.addSubview(tableView)
        constrain(self.view, tableView){view, tableView  in
            view.edges == tableView.edges
        }
        tableView.register(SearchTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 60.0
        tableView.tableFooterView = UIView()
    }
}

// MARK: tableView Delegates methods

extension SearchViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return tagResult.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagResult[section].tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SearchTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let text = String.attributedText(withString: tagResult[indexPath.section].tags[indexPath.row], boldString: searchText, font: (cell.textLabel?.font)!)
        cell.textLabel?.attributedText = nil
        cell.textLabel?.attributedText = text
        
        switch tagResult[indexPath.section].type {
        case .city, .adress, .country : cell.imageView?.image = #imageLiteral(resourceName: "icons8-marker-filled-40.png")
        case .year, .month : cell.imageView?.image = #imageLiteral(resourceName: "icons8-calendar-filled-40.png")
        case .recent : cell.imageView?.image = #imageLiteral(resourceName: "icons8-time-machine-40 (1).png")
        default:  cell.imageView?.image = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        guard let text = cell?.textLabel?.text else {
            userAlert(title: "Something went wrong", message: "please try again")
            return
        }
        var type = tagResult[indexPath.section].type
        viewModel.saveSearched(tag:text, type: type)
        if type == .recent { type = viewModel.getOriginlTypeFor(tag: text)! }
        pushSearchAlbum(tag: text, type: type)
    }

    
    func pushSearchAlbum(tag:String, type:SearchSectionType){
        
        viewModel.getAssets(tagName: tag, sectionType: type)
        let vc = PhotoController(albumName: "Search")
        let pushAlbumData = PushAlbumData(albumName: "Search",tabType: .albumGrid, albumType: .search)
        vc.didSelectPhoto = showPhotoFromAlbum
        vc.pushAlbumData = pushAlbumData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showPhotoFromAlbum(_ segueData:SegueData) {
        guard let albumName = segueData.albumName else { return }
        let detailVC = PhotoDetail(albumName: albumName)
        detailVC.dismissPhotoDetail = dismissPhotoFromAlbum
        detailVC.segueData = segueData
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func dismissPhotoFromAlbum(_ segueData:DismissData){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = .white
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
      return tagResult[section].name
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchController.searchBar.endEditing(true)

    }
}

// MARK: Search Delegates methods


extension SearchViewController
{
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = true
    }
    
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.showsCancelButton = true
        
        return true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.setShowsCancelButton(true, animated: false)
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.dismiss(animated: false, completion: nil)
//        dismissView()
    }
    
    func updateSearchResults(for searchController: UISearchController) {

        guard let text = searchController.searchBar.text else {
            return
        }
        searchText = text
        tagResult.removeAll()
        viewModel.getTags(forText: text, complitionHandler: { (result) in
            switch result{
            case .success(let tags): tagResult = tags
            case .error(let error):print(error)
            }
        })
        

    }
}
