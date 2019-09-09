using System;
using System.IO;
using System.Text;

namespace WorkdayAutomationAegis
{
  class ErrorLogging
  {
    public static void WriteToErrorFile(Exception ex,string suggestedAction)
    {
      using (StreamWriter errWriter = new StreamWriter(Directory.GetCurrentDirectory() + "\\ErrorLog.txt"))
      {
        errWriter.WriteLine(DateTime.Now.ToString()+" - ErrSource: "+ex.Source.ToString()+" - ErrMessage: "+ex.Message.ToString()+" "+suggestedAction);
      }
    }
  }
}
