//
//  MemoryDataSource.m
//  project2 part 3
//
//  Created by Tony Albor on 2/13/14.
//  Copyright (c) 2014 tonyalbor. All rights reserved.
//

#import "MemoryDataSource.h"
#import <fstream>
#import <iostream>
//#import <unistd.h>
#import <dirent.h>
#import <sys/types.h>

@implementation MemoryDataSource

static MemoryDataSource *_sharedDataSource = nil;

+ (MemoryDataSource *)sharedDataSource {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataSource = [[MemoryDataSource alloc] init];
    });
    return _sharedDataSource;
}

- (void)saveData {
    
    DIR *dp;
	dirent *d;
    
    /*
	if((dp = opendir(argv[1])) != NULL)
		perror("opendir");
    
	while((d = readdir(dp)) != NULL)
	{
		if(!strcmp(d->d_name,".") || !strcmp(d->d_name,".."))
			continue;
        
		cout << d->d_name << endl;
	}
     */
    /*
    std::ofstream stream;//("Events.csv");
    stream.open("Events.csv");
    if(stream.is_open())
    stream << "0,1,2,3,4,5,6,7,8";
    else NSLog(@"not open again");
    stream.close();
    
    
    std::ifstream istream("Events.csv");
    if(istream.is_open()) {
        NSLog(@"nice, it's open");
        std::string line;
        std::getline(istream,line);
        std::cout << "\n\n Here we go mutha fucka: \n" << line << std::endl << std::endl;
    } else {
        NSLog(@"shits not open");
    }
    */
    return;
}

@end
