﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------
using System;
using DevExpress.Xpo;
using DevExpress.Xpo.Metadata;
using DevExpress.Data.Filtering;
using System.Collections.Generic;
using System.ComponentModel;
using System.Reflection;
namespace AI.Automation
{

    [Persistent(@"AI.SourceValueOverride")]
    public partial class AISourceValueOverride : XPObject
    {
        string fSourceFieldName;
        [Size(SizeAttribute.Unlimited)]
        public string SourceFieldName
        {
            get { return fSourceFieldName; }
            set { SetPropertyValue<string>(nameof(SourceFieldName), ref fSourceFieldName, value); }
        }
        string fSourceValue;
        [Size(SizeAttribute.Unlimited)]
        public string SourceValue
        {
            get { return fSourceValue; }
            set { SetPropertyValue<string>(nameof(SourceValue), ref fSourceValue, value); }
        }
        string fOverrideValue;
        [Size(SizeAttribute.Unlimited)]
        public string OverrideValue
        {
            get { return fOverrideValue; }
            set { SetPropertyValue<string>(nameof(OverrideValue), ref fOverrideValue, value); }
        }
        string fComment;
        [Size(SizeAttribute.Unlimited)]
        public string Comment
        {
            get { return fComment; }
            set { SetPropertyValue<string>(nameof(Comment), ref fComment, value); }
        }
    }

}
