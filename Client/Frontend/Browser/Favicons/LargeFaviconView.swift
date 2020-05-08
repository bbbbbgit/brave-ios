// Copyright 2020 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import BraveShared

class LargeFaviconView: UIView {
    
    var siteURL: URL? {
        didSet {
            if let url = siteURL, !url.absoluteString.isEmpty {
                monogramFallbackLabel.text = url.baseDomain?.first?.uppercased()
                
                fetcher = NewFaviconFetcher(siteURL: url, kind: .appleTouchIcon)
                fetcher?.load { [weak self] attributes in
                    guard let self = self, self.siteURL == url else { return }
                    self.monogramFallbackLabel.isHidden = attributes.image != nil
                    self.imageView.image = attributes.image
                    self.imageView.contentMode = attributes.contentMode
                    self.backgroundColor = attributes.backgroundColor
                    self.layoutMargins = .init(equalInset: attributes.includePadding ? 4 : 0)
                    self.backgroundView.isHidden = !attributes.includePadding
                }
            } else {
                fetcher = nil
                monogramFallbackLabel.text = nil
                monogramFallbackLabel.isHidden = true
                imageView.image = nil
            }
        }
    }
    
    private var fetcher: NewFaviconFetcher?
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let monogramFallbackLabel = UILabel().then {
        $0.appearanceTextColor = .white
        $0.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.height > 0 {
            monogramFallbackLabel.font = .systemFont(ofSize: bounds.height / 2)
        }
    }
    
    private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .regular)).then {
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 8
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
        
        clipsToBounds = true
        layer.borderColor = BraveUX.faviconBorderColor.cgColor
        layer.borderWidth = BraveUX.faviconBorderWidth
        
        layoutMargins = .zero
        
        addSubview(backgroundView)
        addSubview(monogramFallbackLabel)
        addSubview(imageView)
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.center.equalTo(self)
            $0.leading.top.greaterThanOrEqualTo(layoutMarginsGuide)
            $0.trailing.bottom.lessThanOrEqualTo(layoutMarginsGuide)
        }
        monogramFallbackLabel.snp.makeConstraints {
            $0.center.equalTo(self)
        }
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError()
    }
}
