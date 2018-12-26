//
//  MainViewController.swift
//  nail
//
//  Created by Zhaoyu Yan on 12/12/18.
//  Copyright © 2018 Zhaoyu Yan. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MainViewController: UIViewController, UITextFieldDelegate, GMSAutocompleteViewControllerDelegate, UICollisionBehaviorDelegate{
    static var placeId:String?
    static var placeName:String?
    static var placeAddress:String?
    
    var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var searchTextField: UITextField!
    
    var commentsVC:CommentsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(view.bounds)
        
        let userDetailBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        let imageData = NSData(bytes: LoginViewController.user!.photo.data, length: LoginViewController.user!.photo.data.count)
        var userDetailImage = UIImage(data:imageData as! Data)!.resizeImage(targetSize: CGSize(width: 34, height: 34)).maskRoundedImage(radius: 17)
        userDetailBtn.imageView?.contentMode = .scaleAspectFit
        userDetailBtn.setImage(userDetailImage, for: .normal)
        userDetailBtn.addTarget(self, action: #selector(toUserDetailVC), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: userDetailBtn)
        
        initMapView()
        initMakeUpView()
        initSearchTextField()
        initCommentsVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        commentsVC.getComments()
    }
    
    @objc func toUserDetailVC(){
        performSegue(withIdentifier: "toUserDetailVC", sender: self)
    }
    
    
    
    func initMapView(){
        let camera = GMSCameraPosition.camera(withLatitude: 42.339753, longitude: -71.089088, zoom: 17)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height-350), camera: camera)
        view.addSubview(mapView)
    }
    
    func initMakeUpView(){
        let makeUpView = UIView(frame: CGRect(x: 0, y: self.view.bounds.height-355, width: self.view.bounds.width, height: 355))
        makeUpView.backgroundColor = .green
        let findMeLabel = UILabel(frame: CGRect(x: makeUpView.center.x-150, y: 100, width: 300, height: 70))
        findMeLabel.text = "You Find me!"
        findMeLabel.textAlignment = .center
        findMeLabel.textColor = .purple
        findMeLabel.adjustsFontSizeToFitWidth = true
        makeUpView.addSubview(findMeLabel)
        self.view.addSubview(makeUpView)
    }
    
    func initSearchTextField(){
        searchTextField = UITextField(frame: CGRect(x: view.center.x-150, y: 130, width: 300, height: 50))
        searchTextField.adjustsFontSizeToFitWidth = true
        searchTextField.backgroundColor = .white
        searchTextField.layer.borderWidth = 2
        searchTextField.layer.borderColor = UIColor.green.cgColor
        searchTextField.placeholder = "Search any place"
        let leftImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        leftImageView.image = UIImage(named: "searchIcon")
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        paddingView.addSubview(leftImageView)
        searchTextField.leftView = paddingView
        searchTextField.leftViewMode = .always
        searchTextField.delegate = self
        view.addSubview(searchTextField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let autoCompleteViewController = GMSAutocompleteViewController()
        autoCompleteViewController.delegate = self
        
        let filter = GMSAutocompleteFilter()
        autoCompleteViewController.autocompleteFilter = filter
        
        self.locationManager.startUpdatingLocation()
        present(autoCompleteViewController, animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        
        var zoom:Float = 17
        let addressesForZoom: [String] = place.formattedAddress!.components(separatedBy: ",")
        switch addressesForZoom.count{
        case 1:
            zoom = 5
        case 2:
            zoom = 10
        case 3:
            zoom = 14
        case 4:
            zoom = 17
        default:
            zoom = 17
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: zoom)
        mapView.camera = camera

        searchTextField.text = place.name
        commentsVC.nameText = place.name
        commentsVC.addressText = place.formattedAddress ?? ""
        MainViewController.placeId = place.placeID
        MainViewController.placeName = place.name
        MainViewController.placeAddress = place.formattedAddress ?? ""
        commentsVC.getComments()
        
        mapView.clear()
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = place.name
        marker.snippet = place.formattedAddress
        marker.map = mapView
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error auto complete: \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*-----------------------------------------------------------*/
    /*-----------------------------------------------------------*/
    /*-----------------------------------------------------------*/
    /*  bottom up view controller*/
    
    var commentsView: UIView!
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var snap: UISnapBehavior!
    var previousTouchPoint:CGPoint!
    var viewDragging = false
    var viewPinned = false
    let intID1 = IntIdentifier(1)
    let intID2 = IntIdentifier(2)
    
    func initCommentsVC(){
        
        animator = UIDynamicAnimator(referenceView: self.view)
        gravity = UIGravityBehavior()
        
        animator.addBehavior(gravity)
        gravity.magnitude = 4
    
        addCommentsVC(atOffset: 355)
    }
    
    func addCommentsVC(atOffset offset:CGFloat) -> UIView?{
        let frameForView = self.view.bounds.offsetBy(dx: 0, dy: self.view.bounds.height - offset)
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        commentsVC = sb.instantiateViewController(withIdentifier: "commentsVC") as! CommentsViewController
        
        if let view = commentsVC.view{
            view.frame = frameForView
            view.layer.cornerRadius = 5
            view.layer.shadowOffset = CGSize(width: 2, height: 2)
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowRadius = 3
            view.layer.shadowOpacity = 0.5
            
            self.addChild(commentsVC)
            self.view.addSubview(view)
            commentsVC.didMove(toParent: self)
            
            let panGestureRecongizer = UIPanGestureRecognizer(target: self, action: #selector(MainViewController.handlePan(gestureRecognizer:)))
            view.addGestureRecognizer(panGestureRecongizer)
            
            let collision = UICollisionBehavior(items: [view])
            collision.collisionDelegate = self
            animator.addBehavior(collision)
            
            let boundary = view.frame.origin.y+view.frame.size.height
            var boundaryStart = CGPoint(x: 0, y: boundary)
            var boundaryEnd = CGPoint(x:self.view.bounds.width, y:boundary)
            collision.addBoundary(withIdentifier: intID1, from: boundaryStart, to: boundaryEnd)
            
            boundaryStart = CGPoint(x:0, y:0)
            boundaryEnd = CGPoint(x: self.view.bounds.width, y: 0)
            collision.addBoundary(withIdentifier: intID2 , from: boundaryStart, to: boundaryEnd)
            
            gravity.addItem(view)
            
            let itemBehavior = UIDynamicItemBehavior(items: [view])
            animator.addBehavior(itemBehavior)
            return view
        }
        
        return nil
    }
    
    @objc func handlePan(gestureRecognizer:UIPanGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: self.view)
        let draggedView = gestureRecognizer.view!
        
        if gestureRecognizer.state == .began{
            let dragStartPoint = gestureRecognizer.location(in: draggedView)
            
            if dragStartPoint.y<80 {
                viewDragging = true
                previousTouchPoint = touchPoint
            }
        }else if gestureRecognizer.state == .changed && viewDragging{
            let yOffset = previousTouchPoint.y - touchPoint.y
            draggedView.center = CGPoint(x: draggedView.center.x, y: draggedView.center.y-yOffset)
            previousTouchPoint = touchPoint
        }else if gestureRecognizer.state == .ended && viewDragging{
            //pin
            pin(view: draggedView)
            // addVelocity
            addVelocity(toView: draggedView, fromGestureRecognizer: gestureRecognizer)
            animator.updateItem(usingCurrentState: draggedView)
            viewDragging = false
        }
        
    }
    
    func pin(view:UIView){
        let viewHasReachedPinLocation = view.frame.origin.y < 180
        
        if viewHasReachedPinLocation{
            if !viewPinned{
                var snapPosition = self.view.center
                snapPosition.y += 70
                snap = UISnapBehavior(item: view, snapTo: snapPosition)
                animator.addBehavior(snap)
                viewPinned = true
            }
        }else{
            if viewPinned {
                animator.removeBehavior(snap)
                //setVisibility(view: view, alpha: 1)
                viewPinned = false
            }
        }
    }
    
    func addVelocity (toView view:UIView, fromGestureRecognizer panGesture:UIPanGestureRecognizer){
        var velocity = panGesture.velocity(in: self.view)
        velocity.x = 0
        
        if let behavior = itemBehavior(forView: view){
            behavior.addLinearVelocity(velocity, for: view)
        }
    }
    
    func itemBehavior (forView view:UIView) -> UIDynamicItemBehavior?{
        for behavior in animator.behaviors{
            if let itemBehavior = behavior as? UIDynamicItemBehavior{
                if let possibleView = itemBehavior.items.first as? UIView, possibleView == view {
                    return itemBehavior
                }
            }
        }
        return nil
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        if identifier === intID2 {
            let view = item as! UIView
            pin(view:view)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class IntIdentifier: NSCopying{
    var id:Int
    init(_ id:Int) {
        self.id = id
    }
    func copy(with zone: NSZone? = nil) -> Any {
        return id
    }
}
