import flash.net.navigateToURL;
import flash.net.URLRequest;

function URLOPEN__( targetURL:String ):void{
	navigateToURL(new URLRequest("http://"+targetURL), "_blank");
}