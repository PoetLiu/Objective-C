//
//  FlickrAPI.m
//  Photorama
//
//  Created by liupeng on 16/4/6.
//  Copyright © 2016年 liupeng. All rights reserved.
//

#import "FlickrAPI.h"
@interface FlickrAPI ()
@property NSString *baseURLString;
@property NSString *APIKey;
@property NSDateFormatter *dateFormatter;
@end

@implementation FlickrAPI
-(instancetype)init {
	if (self = [super init]) {
		self.method	= @{@"RecentPhotos":@"flickr.photos.getRecent"};
		self.baseURLString	= @"https://69.147.76.173/services/rest/";
		self.APIKey	= @"a6d819499131071f158fd740860a5a88";
		self.dateFormatter = [[NSDateFormatter alloc] init];
		self.dateFormatter.dateFormat =  @"yyyy-MM-dd HH:mm:ss";
	}
	return self;
}

-(NSURL *) recentPhotosURL {
	return [self flickrURL:@"RecentPhotos" parameters:@{@"extras":@"url_h,date_taken"}];
}

-(NSURL *) flickrURL:(NSString *)method parameters:(NSDictionary *)param{
	NSURLComponents *components = [[NSURLComponents alloc] initWithString:self.baseURLString];
	NSMutableArray *queryItems = [[NSMutableArray alloc] init];
	NSDictionary *baseParams = @{
			@"method":self.method[method],
			@"format":@"json",
			@"nojsoncallback":@"1",
			@"api_key":self.APIKey};
	
	[baseParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:obj];
		[queryItems addObject:item];
	}];
	
	if (param) {
		[param enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
			NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:obj];
			[queryItems addObject:item];
		}];
		components.queryItems	= queryItems;
	}
	return [components URL];
}

- (NSMutableArray *) photosFromJSONData:(NSData *)data {
	NSError *err;
	id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
	if (err) {
		NSLog(@"err:%@", err);
		return nil;
	}
	
	NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
	NSDictionary *photos = (NSDictionary *)[jsonDictionary objectForKey:@"photos"];
	NSArray *photoArray = (NSArray *)[photos objectForKey:@"photo"];
	if (!photos || !photoArray) {
		NSLog(@"Invalid json data");
		return nil;
	}

	NSMutableArray *finalPhotos = [[NSMutableArray alloc] init];
	for (NSDictionary *photoJSON in photoArray) {
		Photo *photo = [self photoFromJSONObject:photoJSON];
		if (photo) {
			[finalPhotos addObject:photo];
		}
	}
	
	if (finalPhotos.count == 0 && photoArray.count > 0) {
		NSLog(@"Unable to parse any of the photos, Maybe the JSON format for photos has changed");
		return nil;
	}
	return finalPhotos;
}

- (Photo *) photoFromJSONObject:(NSDictionary *)json {
	NSString *photoID = [json objectForKey:@"id"];
	NSString *title	= [json objectForKey:@"title"];
	NSString *dateString = [json objectForKey:@"datetaken"];
	NSString *photoURLString = [json objectForKey:@"url_h"];
	NSURL *url	= [NSURL URLWithString:photoURLString];
	NSDate *dateTaken	= [self.dateFormatter dateFromString:dateString];
	
	if (!photoID || !title || !url || !dateTaken) {
		NSLog(@"Don't have enough information to construct a Photo");
		return nil;
	}
	return [[Photo alloc] initWithTitle:title photoID:photoID remoteURL:url dateTaken:dateTaken];
}

@end
