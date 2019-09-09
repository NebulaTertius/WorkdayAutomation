using System;
using DevExpress.Xpo;
using DevExpress.Data.Filtering;
using System.Collections.Generic;
using System.ComponentModel;
namespace AI.Automation
{

  public partial class AILeaveTransactionQueue
  {
    public AILeaveTransactionQueue(Session session) : base(session) { }
    public override void AfterConstruction() { base.AfterConstruction(); }
  }

}
