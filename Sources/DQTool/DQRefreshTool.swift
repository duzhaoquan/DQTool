//
//  DQRefreshTool.swift
//  
//
//  Created by zhaoquan.du on 4/3/23.
//

import UIKit

/*
 //使用示例：
 
  let refreshControl = DQRefreshTool()
  refreshControl.configView(scrollView: tableView) {[weak self] in
      guard let self = self else{return}
      self.refreshFollowList(isFollowers: self.isFollower)
  }
  refreshControl.setLoadMoreBlock {[weak self] in
      guard let self = self else{return}
      self.viewModel.getFollowList(isFollowers: self.isFollower) { suc, str in
          self.tableView.reloadData()
          if self.isFollower{
              if self.viewModel.followerModels.count >= self.viewModel.followerCount{
                  self.tableView.setDQRfreshState(.noMoreData)
              }else{
                  self.tableView.setDQRfreshState(.idle)
              }
          }else{
              if self.viewModel.followingModels.count >= self.viewModel.followingCount{
                  self.tableView.setDQRfreshState(.noMoreData)
              }else{
                  self.tableView.setDQRfreshState(.idle)
              }
          }
      }
  }
  
 */
//刷新状态机
enum DQRefreshState {
    case idle,refeshing,loading,noMoreData
}
class DQRefreshTool: UIRefreshControl {
    private var refreshBlock: (()-> Void)?
    private var loadMoreBlock: (()-> Void)?
    
    private weak var scrollView:UIScrollView?
    
    var refreshState: DQRefreshState = .idle
    var isSucceed:Bool = true
    
    var refreshView: DQRefreshViewProtocol? {
        willSet{
            refreshView?.removeFromSuperview()
        }
        didSet{
            setUpRefreshView()
        }
    }
    
    init(refreshView: DQRefreshViewProtocol? = nil,refreshBlock: (() -> Void)? = nil) {
        super.init(frame: .zero)
        self.refreshBlock = refreshBlock
        self.refreshView = refreshView
        setUpRefreshView()
        self.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        //print("------ DQRefreshTool deinit ------------")
    }
    
    func setUpRefreshView(){
        if let refreshView = refreshView {
            subviews.forEach({$0.alpha = 0})
            addSubview(refreshView)
            refreshView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                
                refreshView.widthAnchor.constraint(equalTo: widthAnchor),
                refreshView.heightAnchor.constraint(equalTo: heightAnchor),
                refreshView.centerYAnchor.constraint(equalTo: centerYAnchor),
                refreshView.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        }
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        if refreshView != nil {
            subviews.forEach({if $0 !== refreshView{ $0.alpha = 0}})
        }
        
        self.refreshView?.endRefreshing(isSucceed: self.isSucceed)
        self.refreshState = .idle
       
        
    }
    override func beginRefreshing() {
        super.beginRefreshing()
        if refreshView != nil {
            subviews.forEach({if $0 !== refreshView{ $0.alpha = 0}})
        }
        refreshView?.beginRefreshing()
        refreshState = .refeshing
    }
    
    func configView(scrollView: UIScrollView){
        scrollView.refreshControl = self
        self.scrollView = scrollView
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset),options: [.new], context: nil)
    }
    
    func setRefreshBlock(_ refreshBlock: @escaping () -> Void ) {
        self.refreshBlock = refreshBlock
    }
    
    func setLoadMoreBlock(_ loadMoreBlock: @escaping () -> Void ) {
        self.loadMoreBlock = loadMoreBlock
    }
    
    @objc func refreshData() {
        beginRefreshing()
        refreshBlock?()
        
    }
    func loadMoreData(){
        refreshState = .loading
        loadMoreBlock?()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard  self.loadMoreBlock != nil, self.refreshState == .idle, let scrollView = self.scrollView else{
            return
        }
        if keyPath == #keyPath(UIScrollView.contentOffset) {
            if let offSet = change?[.newKey] as? CGPoint {
                //水平方向
                if  ((scrollView as? UICollectionView)?.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == .horizontal {
                    let offsetX = offSet.x
                    let contentWidth = scrollView.contentSize.width
                    let frameWidth = scrollView.frame.width

                    if contentWidth - frameWidth > 0,offsetX - 50 > contentWidth - frameWidth {
                        self.loadMoreData()
                    }
                }
                else{
                    let offsetY = offSet.y
                    let contentHeight = scrollView.contentSize.height
                    let frameHeight = scrollView.frame.height

                    if contentHeight - frameHeight > 0 ,offsetY - 50 > contentHeight - frameHeight{
                        self.loadMoreData()
                    }
                }
            }
        }
    }
    
}
//ScrollView add function
extension  UIScrollView {
    func setDQRfreshState(_ state: DQRefreshState){
        guard  let control = self.refreshControl as? DQRefreshTool else {
            return
        }
        control.refreshState = state
    }
    func endDQRefreshing(isSucceed:Bool) {
        guard  let control = self.refreshControl as? DQRefreshTool else {
            return
        }
        control.isSucceed = isSucceed
        control.endRefreshing()
    }
}

protocol DQRefreshViewProtocol: UIView {
    func beginRefreshing()
    func endRefreshing(isSucceed:Bool)
    
}
class DQRefreshView: UIView,DQRefreshViewProtocol{
    func endRefreshing(isSucceed:Bool) {
        activityView.layer.removeAllAnimations()
    }
    
    func beginRefreshing() {
        activityView.layer.removeAllAnimations()
        let rotation = CABasicAnimation.init(keyPath: "transform.rotation")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1.25
        activityView.layer.add(rotation, forKey: nil)
    }
    
    private var activityView :UIImageView = {
        let dview = UIImageView()
        dview.image = UIImage(named: "iconDisplayLoading")
        dview.translatesAutoresizingMaskIntoConstraints = false
        dview.widthAnchor.constraint(equalToConstant: 30).isActive = true
        dview.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dview.backgroundColor = .white
        
        return dview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        backgroundColor = .clear
        addSubview(activityView)
        NSLayoutConstraint.activate([
            activityView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

/*
 import Kingfisher
 class MXDQRefreshView : UIView,DQRefreshViewProtocol {
     private var gifWidth = 76.0
     var isSucceed = true
     private lazy var gifImageView :AnimatedImageView = {
         var  gifImage = AnimatedImageView()
         gifImage.image = UIImage(named: "loading_refresh")
         gifImage.repeatCount = .infinite
         gifImage.backgroundDecode = true
         gifImage.autoPlayAnimatedImage = true
         gifImage.framePreloadCount = 5
         gifImage.runLoopMode = .common
         gifImage.widthAnchor.constraint(equalToConstant: 76).isActive = true
         gifImage.heightAnchor.constraint(equalToConstant: 76).isActive = true
         
         gifImage.translatesAutoresizingMaskIntoConstraints = false
         return gifImage
     }()
     private lazy var stateLabel:UILabel = {
         let label = UILabel(frame: .zero)
         label.textAlignment = .center
         label.font = UIFont.boldSystemFont(ofSize: 17)
         label.textColor = .black
         label.translatesAutoresizingMaskIntoConstraints = false
         label.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive  = true
         label.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
         label.isHidden = true
         
         return label
     }()
     override init(frame: CGRect) {
         super.init(frame: frame)
         backgroundColor = .white
         setupView()
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     func setupView(){
 //        backgroundColor = .clear
         addSubview(gifImageView)
         addSubview(stateLabel)
         NSLayoutConstraint.activate([
             gifImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
             gifImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
             stateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
             stateLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
         ])
     }
     
     func beginRefreshing() {
         if !gifImageView.isAnimating {
             let path = Bundle.main.path(forResource:"PullDownLoading", ofType:"gif")
             alpha = 1
             gifImageView.kf.setImage(with: URL(fileURLWithPath: path!))
             gifImageView.startAnimating()
         }
     }

     func endRefreshing(isSucceed:Bool) {
         self.isSucceed = isSucceed
         
         if gifImageView.isAnimating {
             gifImageView.stopAnimating()
             gifImageView.isHidden = true
             stateLabel.isHidden = false
             gifImageView.image = UIImage(named: "loading_refresh")
             stateLabel.text = isSucceed ? "succeed" : "failure"
             
             self.alpha = 1
             UIView.animate(withDuration: 0.3, delay: 0) {
                 self.alpha = 0.2
             } completion: {_ in
                 self.alpha = 1
                 self.stateLabel.isHidden = true
                 self.gifImageView.isHidden = false
             }
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                 self.gifImageView.image = UIImage(named: "loading_refresh")
                 self.alpha = 1
                 self.stateLabel.isHidden = true
                 self.gifImageView.isHidden = false
             }

         }else {
             gifImageView.image = UIImage(named: "loading_refresh")
             stateLabel.isHidden = true
             gifImageView.isHidden = false
         }
     }
 }
 */
