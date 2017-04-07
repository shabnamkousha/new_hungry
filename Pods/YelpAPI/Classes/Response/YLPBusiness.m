//
//  Business.m
//  Pods
//
//  Created by David Chen on 1/5/16.
//
//

#import "YLPBusiness.h"
#import "YLPCategory.h"
#import "YLPCoordinate.h"
#import "YLPLocation.h"
#import "YLPResponsePrivate.h"

@implementation YLPBusiness

- (instancetype)initWithDictionary:(NSDictionary *)businessDict {
    if (self = [super init]) {
        _closed = [businessDict[@"is_closed"] boolValue];

        _URL = [[NSURL alloc] initWithString:businessDict[@"url"]];
        NSString *imageURLString = [businessDict ylp_objectMaybeNullForKey:@"image_url"];
        _imageURL = imageURLString.length > 0 ? [[NSURL alloc] initWithString:imageURLString] : nil;
        
        _rating = [businessDict[@"rating"] doubleValue];
        _reviewCount = [businessDict[@"review_count"] integerValue];
        
        _name = businessDict[@"name"];
        _identifier = businessDict[@"id"];
        NSString *phone = [businessDict ylp_objectMaybeNullForKey:@"phone"];
        _phone = phone.length > 0 ? phone : nil;
        
        _categories = [self.class categoriesFromJSONArray:businessDict[@"categories"]];
        YLPCoordinate *coordinate = [self.class coordinateFromJSONDictionary:businessDict[@"coordinates"]];
        _location = [[YLPLocation alloc] initWithDictionary:businessDict[@"location"] coordinate:coordinate];
        
        _price = businessDict[@"price"];
        _distance = [businessDict[@"distance"] doubleValue];
        _businessid = businessDict[@"id"];
        
        NSMutableArray *t_is_overnight = [[NSMutableArray<NSString *> alloc] init];
        NSMutableArray *t_start = [[NSMutableArray<NSString *> alloc] init];
        NSMutableArray *t_end = [[NSMutableArray<NSString *> alloc] init];
        
        NSArray *array = businessDict[@"hours"][@"open"];
        if (array != nil) {
            for (int i = 0; i<7; i++) {
                NSString *a = array[i][@"is_overnight"];
                NSString *b = array[i][@"start"];
                NSString *c = array[i][@"end"];
                
                [t_is_overnight addObject:a];
                [t_start addObject:b];
                [t_end addObject:c];
            }
            _is_overnight = t_is_overnight;
            _start = t_start;
            _end = t_end;
        }
    }
    return self;
}

+ (NSArray *)categoriesFromJSONArray:(NSArray *)categoriesJSON {
    NSMutableArray *mutableCategories = [[NSMutableArray alloc] init];
    
    for (NSDictionary *category in categoriesJSON) {
        [mutableCategories addObject:[[YLPCategory alloc] initWithDictionary:category]];
    }
    return mutableCategories;
}

+ (YLPCoordinate *)coordinateFromJSONDictionary:(NSDictionary *)coordinatesDict {
    NSNumber *latitude = [coordinatesDict ylp_objectMaybeNullForKey:@"latitude"];
    NSNumber *longitude = [coordinatesDict ylp_objectMaybeNullForKey:@"longitude"];
    if (latitude && longitude) {
        return [[YLPCoordinate alloc] initWithLatitude:[latitude doubleValue]
                                             longitude:[longitude doubleValue]];
    } else {
        return nil;
    }
}

@end
