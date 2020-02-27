//
//  LocationTableCell.swift
//  myUberClone
//
//  Created by Sheldon on 2/8/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit
import MapKit

class LocationTableCell: UITableViewCell {
    
    // MARK: Properties
    var placeMark: MKPlacemark?{
        didSet{
            titleLabel.text = placeMark?.name
            addressLabel.text = placeMark?.address
        }
    }

    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    let addressLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        // Create a stack view.
        let stack = UIStackView(arrangedSubviews: [titleLabel,addressLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    
}
