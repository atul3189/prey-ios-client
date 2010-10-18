//
//  ConfigParserDelegate.m
//  Prey
//
//  Created by Carlos Yaconi on 18/10/2010.
//  Copyright 2010 Fork Ltd. All rights reserved.
//

#import "ConfigParserDelegate.h"
#import "DeviceModulesConfig.h"

@interface ConfigParserDelegate ()
	@property (nonatomic) BOOL inMissing;
	@property (nonatomic) BOOL inDelay;
	@property (nonatomic) BOOL inPostUrl;
	@property (nonatomic) BOOL inModules;
	@property (nonatomic) BOOL inModule;
	@property (nonatomic) BOOL inAlertMessage;
	@property (nonatomic, retain) DeviceModulesConfig *modulesConfig;
@end

@implementation ConfigParserDelegate
@synthesize inMissing,inDelay,inPostUrl,inModules,inModule,inAlertMessage,modulesConfig;

- (id) init {
	self = [super init];
	if (self != nil){
        self.modulesConfig = [[DeviceModulesConfig alloc] init];    
		inMissing=NO;
		inDelay=NO;
		inPostUrl=NO;
		inModules=NO;
		inModule=NO;
		inAlertMessage=NO;
	}
    return self;
}

- (DeviceModulesConfig*) parseModulesConfig:(NSData *)response parseError:(NSError **)err {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:response];
	
	[parser setDelegate:self];
	
	[parser setShouldProcessNamespaces:NO]; // We don't care about namespaces
	[parser setShouldReportNamespacePrefixes:NO]; //
	[parser setShouldResolveExternalEntities:NO]; // We just want data, no other stuff
	
	[parser parse]; // Parse that data..
	
	if (err && [parser parserError]) {
		*err = [parser parserError];
	}
	
	[parser release];		
	return self.modulesConfig;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict 
{
	if ([elementName isEqualToString:@"missing"]) 
		self.inMissing = YES;
	else if ([elementName isEqualToString:@"delay"]) 
		self.inDelay = YES;
	else if ([elementName isEqualToString:@"post_url"]) 
		self.inPostUrl = YES;
	else if ([elementName isEqualToString:@"modules"]) 
		self.inModules = YES;
	else if ([elementName isEqualToString:@"module"]) {
		self.inModule = YES;
		if (self.inModules) {
			
			NSString *name = [attributeDict objectForKey:@"name"];
			NSString *active = [attributeDict objectForKey:@"active"];			
			[self.modulesConfig addModuleName:name ifActive:active];
		}
	}
	if (self.inModule) {
		if ([elementName isEqualToString:@"alert_message"])
			self.inAlertMessage = YES;
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"missing"]) 
		self.inMissing = NO;
	else if ([elementName isEqualToString:@"delay"]) 
		self.inDelay = NO;
	else if ([elementName isEqualToString:@"post_url"]) 
		self.inPostUrl = NO;
	else if ([elementName isEqualToString:@"modules"]) 
		self.inModules = NO;
	else if ([elementName isEqualToString:@"module"])
		self.inModule = NO;
	else if ([elementName isEqualToString:@"alert_message"])
		self.inAlertMessage = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (self.inMissing)
		if ([string isEqualToString:@"true"])
			self.modulesConfig.missing = YES;
		else
			self.modulesConfig.missing = NO;
	else if (self.inDelay)
		self.modulesConfig.delay=[NSNumber numberWithInt:[string intValue]];
	else if (self.inPostUrl)
		self.modulesConfig.postUrl = string;
	else if (self.inAlertMessage)
		[self.modulesConfig addConfigValue:string withKey:@"alert_message" forModuleName:@"alert"];
	
}


- (void)dealloc {
	[super dealloc];
}

@end
