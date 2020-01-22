using System;
using System.IO;
using System.Resources;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Collections.ObjectModel;
using System.Management.Automation;
using System.Management.Automation.Runspaces;


 public class Program{
 	public static void Main(){
 		stuff.Exec();
 	}
 }

public class stuff {
 	public static string Exec(){
 		RunspaceConfiguration rsconfig = RunspaceConfiguration.Create();
		Runspace runspace = RunspaceFactory.CreateRunspace(rsconfig);
		runspace.Open();
		RunspaceInvoke scriptInvoker = new RunspaceInvoke(runspace);
		Pipeline pipeline = runspace.CreatePipeline();

		// TODO: use pipeline.Commands.<some command> to somehow add your logic to the runner
		...

		// added for easier output
		pipeline.Commands.Add("Out-String");
		Collection<PSObject> results = pipeline.Invoke();
		runspace.Close();

		// convert records to strings
		StringBuilder stringBuilder = new StringBuilder();
		foreach (PSObject obj in results) {
			stringBuilder.Append(obj);
		}
		return stringBuilder.ToString().Trim();
	}
}
