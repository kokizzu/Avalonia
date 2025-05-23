//
// Created by Dan Walmsley on 06/05/2022.
// Copyright (c) 2022 Avalonia. All rights reserved.
//

#include "WindowInterfaces.h"
#include "AvnView.h"
#include "WindowImpl.h"
#include "automation.h"
#include "menu.h"
#include "common.h"
#import "WindowBaseImpl.h"
#import "WindowProtocol.h"
#import <AppKit/AppKit.h>

class PopupImpl : public virtual WindowBaseImpl, public IAvnPopup
{
private:
    BEGIN_INTERFACE_MAP()
    INHERIT_INTERFACE_MAP(WindowBaseImpl)
    INTERFACE_MAP_ENTRY(IAvnPopup, IID_IAvnPopup)
    END_INTERFACE_MAP()
    virtual ~PopupImpl(){}
    ComPtr<IAvnWindowEvents> WindowEvents;
    PopupImpl(IAvnWindowEvents* events) : TopLevelImpl(events), WindowBaseImpl(events)
    {
        WindowEvents = events;
        [Window setLevel:NSPopUpMenuWindowLevel];
    }
protected:
    virtual NSWindowStyleMask CalculateStyleMask() override
    {
        return NSWindowStyleMaskBorderless;
    }

public:
    virtual HRESULT Show(bool activate, bool isDialog) override
    {
        auto windowProtocol = GetWindowProtocol();
        
        [windowProtocol setEnabled:true];
        
        return WindowBaseImpl::Show(activate, true);
    }
    
    virtual bool ShouldTakeFocusOnShow() override
    {
        auto parent = Parent.tryGet();
        // Don't steal the focus from another windows if our parent is inactive
        if (parent != nullptr && parent->Window != nullptr && ![parent->Window isKeyWindow])
            return false;

        return WindowBaseImpl::ShouldTakeFocusOnShow();
    }
};


extern IAvnPopup* CreateAvnPopup(IAvnWindowEvents*events)
{
    @autoreleasepool
    {
        IAvnPopup* ptr = dynamic_cast<IAvnPopup*>(new PopupImpl(events));
        return ptr;
    }
}
