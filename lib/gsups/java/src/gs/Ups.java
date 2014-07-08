package gs;

import java.io.*;
import java.awt.*;
import java.awt.event.*;
import java.applet.*;
import java.net.*;
import javax.swing.*;
import javax.swing.border.*;

import opt.*;


public class  Ups  extends JApplet implements ActionListener {




	private final String	version 		= Version.string;









	private final String 	ACTION_SELECT 	= "select";
	private final int		blockSize		= 1048576; // * 3; //524288;

  private final String[] fileTypes = {"3g2","3gp","3gp2","3gpp","asf","avi","avs","dv","flc","fli","flv","gvi","m1v","m2v","m4e","m4u","m4v","mjp","mkv","moov","mov","movie","mp4","mpe","mpeg","mpg","mpv2","qt","rm","ts","vfw","vob","wm","wmv"};
  
	private final String 	CALL_JS_LOG 			= "gs.file_assets.log";
	private final String 	CALL_JS_FILE_READY 		= "gs.file_assets.ready_to_upload";
	private final String 	CALL_JS_NOTE_PROGRESS	= "gs.file_assets.note_progress";
	
	private JLabel          detailLabel  = null;
	private JLabel          consoleLabel  = null;
	private JButton         selectButton  = null;
	//private JProgressBar    progressBar   = null;

	private File			file			= null;
	private FileInputStream fileInputStream	= null;
//	private BufferedReader  reader        	= null;


	private int blockCount;
	private int blocksGiven = 0;


	public void init() {
		try {
			
			uiInit();

		}catch(Exception e){ throw new RuntimeException(e); }
	}



	 private void console(String msg){
	   consoleLabel.setText(msg);
	 }

	private void log(String s)
	{
		callJS( CALL_JS_LOG, s );
	}
	
	//
	// Javascript Interface
	//
	
	public String version() {
		return this.version;
	}

	public static void printGreeting(String... names) {
	         
	       }
	
	
	 private void callJS(String f, Object... argv){
		try{

			StringBuffer cmd_line = new StringBuffer();
			cmd_line.append(f);
			cmd_line.append('(');
			
			String comma = "";
			
			for (Object a : argv) {
				Class c = a.getClass();
				
				cmd_line.append(comma);
				
				if(c == String.class){
					cmd_line.append("'");
					cmd_line.append(a);
					cmd_line.append("'");
				}else
				if(c == Integer.class){	
					cmd_line.append(a);
				}else{
					throw new Exception("Argument type "+c+" not supported");
				}
				
				comma = ","; // for the next round
			}

			cmd_line.append(')');
			
			String cmd = cmd_line.toString();
			
			//this.console(cmd);
			
			getAppletContext().showDocument(new URL("javascript:"+cmd));

  		}catch(Exception e){ throw new RuntimeException(e); }
	 }

	public int getBlockCount()
	{
		this.log("getBlockCount()");
		return this.blockCount;
	}

	public int getBlockNumber()
	{
		this.log("getBlockNumber()");
		return this.blocksGiven;
	}

	public String getBlock()
	{
		try{
			//Watch w = new Watch("getBlock()");
			long w = System.nanoTime();
			
			this.console("Uploading "+file.getName());
			//progressBar.setIndeterminate(false);

			int block = ++blocksGiven;
//			this.log("***************************************");
			String s = "getBlock "+block+" of "+blockCount;
			log(s); //+" from "+ file.data.bytesAvailable);

			//TODO cache if blocksize stays fixed
			byte[] buffer = new byte[blockSize];
		
			int bytesRead = fileInputStream.read(buffer);
			
			if(bytesRead == 0)
				return null;

			String packet = Base64.encodeBytes( buffer, 0, bytesRead );

			callJS( CALL_JS_NOTE_PROGRESS, block, blockCount );
			
			//progressBar.setVisible(true);
			//progressBar.setValue(block);
			this.log("getBlock(): "+block+" of "+blockCount+", "+bytesRead+" bytes read.");

			this.log("getBlock().time: "+(System.nanoTime()-w));

			return packet;
			
		}catch(Exception e){ throw new RuntimeException(e); }
	}

	public void panic()
	{
		this.console("Transmission Disrupted - Trying to Resume");
		//progressBar.setIndeterminate(true);
	}

	public void success()
	{
		this.console("Success!");
	}






	//
	// UI
	//

  
	private void uiInit() throws Exception {

		JPanel pane = new JPanel();
		pane.setBounds(new Rectangle(0, 0, 600, 50));
		pane.setLayout(null);
		//pane.setBorder(BorderFactory.createEtchedBorder(EtchedBorder.LOWERED));
		//pane.setBackground(new Color(221, 194, 219));


		consoleLabel = new JLabel("Select a file to upload...");
		consoleLabel.setBounds(new Rectangle(140, 8, 460, 30));
		
		selectButton = new JButton();
		selectButton.setBounds(new Rectangle(16, 8, 120, 30));
		selectButton.setText("Select File");
		selectButton.setActionCommand(ACTION_SELECT);
		selectButton.addActionListener(this);

		//progressBar = new JProgressBar();
		//progressBar.setValue(25);
		//progressBar.setStringPainted(true);
		//progressBar.setBounds(new Rectangle(16, 46, 400, 30));
		//progressBar.setVisible(false);

		detailLabel = new JLabel(this.version, JLabel.RIGHT);
		detailLabel.setForeground(Color.lightGray);
		detailLabel.setBackground(Color.yellow);
		detailLabel.setBounds(new Rectangle(420, 30, 60, 30));
		


		pane.add(selectButton);
		pane.add(consoleLabel);
		//pane.add(progressBar);
		pane.add(detailLabel);

		setContentPane(pane);
	}



	public void actionPerformed(ActionEvent e) {
	  	if (e.getActionCommand().equals(ACTION_SELECT)) {
			this.selectFile();
    	}
	}

	public void selectFile() {
		try{

			FileDialog fd = new FileDialog(new Frame(), "Please select a file to upload:", FileDialog.LOAD);

      fd.setFilenameFilter( new FilenameFilter() {
        public boolean accept(File dir, String name) {
          //final Iterator<String> list = fileTypes.iterator();
          //while (list.hasNext()) {
          for (String type : fileTypes) {
            if (name.toLowerCase().endsWith(type)) {
              return true;
            }
          }
          return false;
        }
      });

			fd.show();

			if (fd.getFile() != null) {

			this.file = new File(fd.getDirectory(), fd.getFile());

				console("Ready to upload: "+this.file.getName());
				
				this.blockCount = (int)Math.ceil((double)this.file.length()/(double)blockSize);

				double d = ((double)this.file.length()/(double)blockSize);
				int i = (int)(this.file.length()/blockSize);

				log(this.file.length() +" bytes, "+blockCount+" blocks");
				log( d+" d, "+i+" i");



				this.console("Ready to Upload "+this.file.getName());

				//callJS( CALL_JS_FILE_READY+"('"+this.file.getName()+"',"+blockCount+")" );
				callJS( CALL_JS_FILE_READY, this.file.getName(), blockCount );


				this.fileInputStream =  new FileInputStream(this.file);
				//this.reader = new BufferedReader(new InputStreamReader(fin));


				//progressBar.setMinimum(0);
				//progressBar.setMaximum(blockCount);
				//progressBar.setIndeterminate(true);
				//progressBar.setVisible(false);


			}

		}catch(Exception e){ throw new RuntimeException(e); }
	}




  public int ping(String msg){
    console(msg);
    return 98;
  }

}
