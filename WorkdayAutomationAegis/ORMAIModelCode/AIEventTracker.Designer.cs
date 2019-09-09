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

    [Persistent(@"AI.EventTracker")]
    public partial class AIEventTracker : XPObject
    {
        string fQueueType;
        public string QueueType
        {
            get { return fQueueType; }
            set { SetPropertyValue<string>(nameof(QueueType), ref fQueueType, value); }
        }
        string fTrackerComment;
        [Size(SizeAttribute.Unlimited)]
        public string TrackerComment
        {
            get { return fTrackerComment; }
            set { SetPropertyValue<string>(nameof(TrackerComment), ref fTrackerComment, value); }
        }
        DateTime fTrackerCreatedDate;
        public DateTime TrackerCreatedDate
        {
            get { return fTrackerCreatedDate; }
            set { SetPropertyValue<DateTime>(nameof(TrackerCreatedDate), ref fTrackerCreatedDate, value); }
        }
        int fSourceOID;
        public int SourceOID
        {
            get { return fSourceOID; }
            set { SetPropertyValue<int>(nameof(SourceOID), ref fSourceOID, value); }
        }
        string fSourceComment;
        [Size(SizeAttribute.Unlimited)]
        public string SourceComment
        {
            get { return fSourceComment; }
            set { SetPropertyValue<string>(nameof(SourceComment), ref fSourceComment, value); }
        }
        string fFieldName;
        [Size(SizeAttribute.Unlimited)]
        public string FieldName
        {
            get { return fFieldName; }
            set { SetPropertyValue<string>(nameof(FieldName), ref fFieldName, value); }
        }
        string fPreProcessValue;
        [Size(SizeAttribute.Unlimited)]
        public string PreProcessValue
        {
            get { return fPreProcessValue; }
            set { SetPropertyValue<string>(nameof(PreProcessValue), ref fPreProcessValue, value); }
        }
        string fQueueValue;
        [Size(SizeAttribute.Unlimited)]
        public string QueueValue
        {
            get { return fQueueValue; }
            set { SetPropertyValue<string>(nameof(QueueValue), ref fQueueValue, value); }
        }
        string fPostProcessValue;
        [Size(SizeAttribute.Unlimited)]
        public string PostProcessValue
        {
            get { return fPostProcessValue; }
            set { SetPropertyValue<string>(nameof(PostProcessValue), ref fPostProcessValue, value); }
        }
    }

}