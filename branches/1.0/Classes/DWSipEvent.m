/*
 * Copyright (C) 2010 Mamadou Diop.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango.org>
 *       
 * This file is part of idoubs Project (http://code.google.com/p/idoubs)
 *
 * idoubs is free software: you can redistribute it and/or modify it under the terms of 
 * the GNU General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 *       
 * idoubs is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 * See the GNU General Public License for more details.
 *       
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */

#import "DWSipEvent.h"

#import "DWMessage.h"
#import "DWSipSession.h"

/* ======================== DWSipEvent ========================*/
@implementation DWSipEvent

@synthesize baseType;
@synthesize code;
@synthesize stack;
@synthesize event;
//@synthesize phrase;

-(DWSipEvent*) initWithEvent: (tsip_event_t*) _event{
	self = [super init];
	if(self){
		self->event = tsk_object_ref(_event);
		self->baseType = self->event->type;
		self->code = self->event->code;	
		
		if(_event->ss){ // Could be null for stack-events
			const tsip_stack_handle_t* stack_handle = tsip_ssession_get_stack(_event->ss);
			const void* userdata;
			if(stack_handle && (userdata = tsip_stack_get_userdata(stack_handle))){
				self->stack = ((DWSipStack*)userdata);
			}
		}
	}
	
	return self;
}


-(NSString*) phrase{
	if(self->phrase == nil){
		self->phrase = [[NSString alloc] initWithCString:event->phrase];
	}
	return self->phrase;
}


-(DWSipSession*) baseSession{
	return (DWSipSession*)(tsip_ssession_get_userdata(self->event->ss));
}

-(DWSipMessage*) message{
	if(self->message == nil){
		self->message = [[DWSipMessage alloc] initWithMessage:self->event->sipmessage];
	}
	return self->message;
}


-(void) dealloc{
	TSK_OBJECT_SAFE_FREE(self->event);
	[self->message release];
	[self->phrase release];
	
	[super dealloc];
}

@end



/* ======================== DWDialogEvent ========================*/
@implementation DWDialogEvent

-(DWDialogEvent*) initWithEvent: (tsip_event_t*) _event{
	self = (DWDialogEvent*)[super initWithEvent:_event];
	return self;
}

-(void) dealloc{	
	[super dealloc];
}

@end

/* ======================== DWStackEvent ========================*/
@implementation DWStackEvent

-(DWStackEvent*) initWithEvent: (tsip_event_t*) _event{
	self = (DWStackEvent*)[super initWithEvent:_event];
	return self;
}

-(void) dealloc{	
	[super dealloc];
}

@end



/* ======================== DWRegistrationEvent ========================*/
@implementation DWRegistrationEvent

@synthesize type;
@synthesize session;

-(DWRegistrationEvent*) initWithEvent: (tsip_event_t*) _event{
	self = (DWRegistrationEvent*)[super initWithEvent:_event];
	if(self){
		self->type = TSIP_REGISTER_EVENT(self->event)->type;
		self->session = [[self.baseSession isMemberOfClass:[DWRegistrationSession class]] ? ((DWRegistrationSession*)self.baseSession) : nil retain];
	}
	return self;
}

+(NSString*) name{
	return @"RegistrationEvent";
}

-(void) dealloc{
	[self->session release];
	[super dealloc];
}

@end


/* ======================== DWInviteEvent ========================*/
@implementation DWInviteEvent

@synthesize type;
@synthesize session;

-(DWInviteEvent*) initWithEvent: (tsip_event_t*) _event{
	self = (DWInviteEvent*)[super initWithEvent:_event];
	if(self){
		self->type = TSIP_INVITE_EVENT(self->event)->type;
		self->session = [[self.baseSession isMemberOfClass:[DWInviteSession class]] ? ((DWInviteSession*)self.baseSession) : nil retain];
	}
	return self;
}

-(DWCallSession*) takeCallSessionOwnership{
	if(self.stack){
		if(self->event && self->event->ss && !tsip_ssession_have_ownership(self->event->ss)){
			/* The constructor will call take_ownerhip() */
			return (DWCallSession*)[[DWCallSession alloc] initWithStack:self.stack andHandle: self->event->ss];
		}
	}
	return nil;
}

-(DWMsrpSession*) takeMsrpSessionOwnership{
	return nil;
}

+(NSString*) name{
	return @"InviteEvent";
}

-(void) dealloc{
	[self->session release];
	[super dealloc];
}

@end