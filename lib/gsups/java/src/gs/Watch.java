package gs;


public class Watch {

	private String label;
	private long stamp;

	public void Watch(String label) {
		this.label = label;
		this.stamp = System.nanoTime();
	}
	
	public String status(){
		return label + ": " + (System.nanoTime() - stamp);
	}

}


