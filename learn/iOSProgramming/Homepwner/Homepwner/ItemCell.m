//
//  ItemCell.m
//  Homepwner
//
//  Created by liupeng on 16/3/25.
//  Copyright © 2016年 liupeng. All rights reserved.
//

#import "ItemCell.h"

@implementation ItemCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) updateLabels {
	UIFont * bodyFont	= [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	self.nameLabel.font	= bodyFont;
	self.valueLabel.font	= bodyFont;
	
	UIFont *caption1Font	= [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
	self.serialNumberLabel.font	= caption1Font;
}
@end
