/**
 * Login form
 * @author Evgenios Skitsanos
 */

package com.skitsanos.aswing.ui
{
	import flash.events.Event;
	import flash.system.Capabilities;

	import org.aswing.ASColor;
	import org.aswing.GridLayout;
	import org.aswing.JButton;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JTextField;

	public class formLogin
	{
		private var oc:Object;
		private var lblStatus:JLabel;

		//constructor
		public function formLogin(container:Object):void
		{
			oc = container;
		}

		//renders login dialog on screen
		public function show():void
		{
			var frame:JFrame = new JFrame(oc, "Login (" + Capabilities.os + "/" + Capabilities.language + ")", true);	//pop-up as modal window
			frame.setClosable(false);	//not allow to close the form
			frame.setResizable(false);	//not alllow to resize the form
			frame.setSizeWH(320, 160);
			frame.show();

			//cunstruct new content panel
			var pane:JPanel = new JPanel(new GridLayout(3, 2, 5, 5));
			pane.setLocationXY(0, 30);
			pane.setSizeWH(320, 90);

			frame.addChild(pane);

			var lblUsername:JLabel = new JLabel("Username:");
			lblUsername.setLocationXY(10, 10);
			lblUsername.setSizeWH(100, 20);
			pane.append(lblUsername);

			var lblPassword:JLabel = new JLabel("Password:");
			lblPassword.setLocationXY(10, 40);
			lblPassword.setSizeWH(100, 20);
			pane.append(lblPassword);

			pane.append(new JPanel()); //add empty cell content into row[3]/col[1]

			var txtUsername:JTextField = new JTextField("");
			txtUsername.setLocationXY(110, 10);
			txtUsername.setSizeWH(100, 20);
			pane.append(txtUsername);

			var txtPassword:JTextField = new JTextField("");
			txtPassword.setLocationXY(110, 40);
			txtPassword.setSizeWH(100, 20);
			pane.append(txtPassword);

			lblStatus = new JLabel("Iddle", null, 2);
			lblStatus.setForeground(new ASColor(0x888888));
			lblStatus.setLocationXY(110, 55);
			lblStatus.setSizeWH(200, 40);
			pane.append(lblStatus);

			var btnOk:JButton = new JButton("Login");
			btnOk.setLocationXY(30, 120);
			btnOk.setSizeWH(70, 20);
			frame.addChild(btnOk);

			var btnCancel:JButton = new JButton("Cancel");
			btnCancel.setLocationXY(110, 120);
			btnCancel.setSizeWH(70, 20);
			btnCancel.addEventListener("click", btnCancel_Click);
			frame.addChild(btnCancel);
		}

		private function btnOk_Click(e:Event):void
		{

		}

		private function btnCancel_Click(e:Event):void
		{
			e.currentTarget.setEnabled(false);
		}
	}

}
